/* ════════════════════════════════════════════════════════════════
   STRIDE NUTRITION — APP LOGIC
   Fixes applied:
     1. Correct Gemini models only (no hallucinated model names)
     2. Camera overlay bug fixed (display vs class)
     3. Portion chip active-chip bug fixed via JS
     4. Camera reset fully functional
════════════════════════════════════════════════════════════════ */

'use strict';

// ── CONSTANTS ────────────────────────────────────────────────────
const CALORIE_GOAL  = 2000;
const PROTEIN_GOAL  = 150;
const CARB_GOAL     = 250;
const FAT_GOAL      = 65;
const STEPS_GOAL    = 10000;
const WATER_GOAL    = 8;
const SLEEP_GOAL    = 8;
const MED_GOAL      = 600;
const SQUATS_GOAL   = 50;

// Only real, confirmed Gemini models — no hallucinated names
const GEMINI_MODELS = [
  { version: 'v1beta', model: 'gemini-1.5-flash' },
  { version: 'v1beta', model: 'gemini-1.5-flash-latest' },
  { version: 'v1beta', model: 'gemini-2.0-flash' },
  { version: 'v1',     model: 'gemini-1.5-flash' },
];

let workingConfig = GEMINI_MODELS[0];

// ── STATE ─────────────────────────────────────────────────────────
let state = {
  apiKey: '',
  today: todayKey(),
  meals: [],
  steps: 0,
  squats: 0,
  setsCompleted: 0,
  water: 0,
  sleep: 0,
  sleepQuality: 'great',
  meditationSec: 0,
  medRunning: false,
  portion: 1,
  chatHistory: [],
  snapshotBase64: null,
  snapshotMime: null,
  cameraStream: null,
  weeklyCalories: {},
};

const NUTRIBOT_SYSTEM = `You are NutriBot, an expert AI nutritionist and fitness coach built into the Stride Nutrition app.
Your personality is warm, motivating, and science-backed. Always respond in the user's language.
Focus on: food quality, macronutrients, hydration, weight management, pre/post-workout nutrition,
healthy habits, sleep, and mindfulness.
Keep answers clear, practical, and encouraging. Use bullet points to make responses readable.
Do not use any emojis in your responses.
Never give medical diagnoses. Always recommend consulting a doctor for health conditions.`;

// ── PERSIST ────────────────────────────────────────────────────────
function saveState() {
  const key = `stride_nutrition_${state.today}`;
  localStorage.setItem(key, JSON.stringify({
    meals: state.meals,
    steps: state.steps,
    squats: state.squats,
    setsCompleted: state.setsCompleted,
    water: state.water,
    sleep: state.sleep,
    sleepQuality: state.sleepQuality,
    meditationSec: state.meditationSec,
    chatHistory: state.chatHistory,
    weeklyCalories: state.weeklyCalories,
  }));
  localStorage.setItem('stride_api_key', state.apiKey);
}

function loadState() {
  state.apiKey = localStorage.getItem('stride_api_key') || '';
  const saved = localStorage.getItem(`stride_nutrition_${state.today}`);
  if (saved) {
    try { Object.assign(state, JSON.parse(saved)); } catch (_) {}
  }
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

// ── GEMINI API ────────────────────────────────────────────────────
async function postGemini(action, body) {
  // Try the last-working config first, then iterate the rest
  const ordered = [workingConfig, ...GEMINI_MODELS.filter(c =>
    !(c.version === workingConfig.version && c.model === workingConfig.model)
  )];

  let lastErr = null;
  for (const cfg of ordered) {
    try {
      const url = `https://generativelanguage.googleapis.com/${cfg.version}/models/${cfg.model}:${action}?key=${state.apiKey}`;
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });

      if (res.ok) {
        workingConfig = cfg; // remember working config
        return await res.json();
      }

      const err = await res.json().catch(() => ({}));
      lastErr = new Error(err?.error?.message || `HTTP ${res.status}`);

      // Only skip to next model on 404/model-not-found errors
      if (res.status === 404 || lastErr.message.includes('not found') || lastErr.message.includes('not supported')) {
        continue;
      }
      throw lastErr; // Bad API key, quota exceeded etc — fail immediately
    } catch (e) {
      if (e.message && !e.message.includes('not found') && !e.message.includes('not supported') && !e.message.includes('HTTP 404')) {
        throw e;
      }
      lastErr = e;
    }
  }
  throw lastErr || new Error('All Gemini model configurations failed.');
}

async function geminiAnalyzeFood(foodText, imageBase64 = null, imageMime = null, portion = 1) {
  if (!state.apiKey) { showModal(); return null; }

  const prompt = `You are a professional nutritionist. Analyze the following food item(s) for ${portion} serving(s).
Respond ONLY with a valid JSON object (no markdown, no code blocks) in this exact format:
{
  "name": "Food name (short, clear)",
  "icon_name": "A Google Material Icon Round name for the food: restaurant (default), local_pizza, cake, icecream, local_cafe, egg, ramen_dining, set_meal, soup_kitchen, bakery_dining, kitchen, flatware, local_bar, brunch_dining, cookie",
  "calories": <number>,
  "protein_g": <number>,
  "carbs_g": <number>,
  "fat_g": <number>,
  "fiber_g": <number>,
  "sugar_g": <number>,
  "vitamins": "e.g. A, C, B12 or None",
  "nutrition_score": "A" | "B" | "C" | "D" | "F",
  "verdict": "One sentence: is this nutritious? Why? (max 20 words)",
  "health_insight": "2-3 sentence health insight about this food and its benefits or drawbacks.",
  "burn_workout": "How to burn these calories: e.g. 35 min jog OR 50 min walk OR 20 min HIIT",
  "is_healthy": true | false
}
Do not use emojis in any part of the output.
Food item: ${foodText || 'food in the image'}`;

  const parts = [{ text: prompt }];
  if (imageBase64 && imageMime) {
    parts.unshift({ inline_data: { mime_type: imageMime, data: imageBase64 } });
  }

  const data = await postGemini('generateContent', {
    contents: [{ role: 'user', parts }],
    generationConfig: { temperature: 0.2, maxOutputTokens: 1024 }
  });

  return parseJsonFromText(data.candidates?.[0]?.content?.parts?.[0]?.text || '');
}

function parseJsonFromText(text) {
  const cleaned = text.replace(/```json|```/g, '').trim();
  try { return JSON.parse(cleaned); } catch (_) {
    const m = cleaned.match(/(\{[\s\S]*\})/);
    if (m) return JSON.parse(m[1]);
    throw new Error('Could not parse Gemini response. Try again.');
  }
}

async function geminiGenerateWorkout(totalKcal, meals) {
  if (!state.apiKey) { showModal(); return null; }
  const mealSummary = meals.map(m => `${m.name} (${m.kcal} kcal)`).join(', ');
  const prompt = `You are a certified fitness trainer. The user consumed ${totalKcal} kcal today from: ${mealSummary || 'various foods'}.
Create a practical daily workout plan. Format as HTML with <h4> headers and <ul><li> bullets.
Include: warm-up, main exercises (cardio + strength), cool-down, rest tips, estimated calories burned.`;

  const data = await postGemini('generateContent', {
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    generationConfig: { temperature: 0.7, maxOutputTokens: 1000 }
  });

  return simpleMarkdownToHtml(data.candidates?.[0]?.content?.parts?.[0]?.text || '');
}

async function geminiChat(userMessage) {
  if (!state.apiKey) { showModal(); return null; }

  const contents = [
    { role: 'user',  parts: [{ text: NUTRIBOT_SYSTEM }] },
    { role: 'model', parts: [{ text: 'Understood! I am NutriBot, ready to help with nutrition and fitness.' }] },
    ...state.chatHistory,
    { role: 'user',  parts: [{ text: userMessage }] }
  ];

  const data = await postGemini('generateContent', {
    contents,
    generationConfig: { temperature: 0.8, maxOutputTokens: 1200 }
  });

  const reply = data.candidates?.[0]?.content?.parts?.[0]?.text || 'Sorry, I could not generate a response.';
  state.chatHistory.push({ role: 'user',  parts: [{ text: userMessage }] });
  state.chatHistory.push({ role: 'model', parts: [{ text: reply }] });
  if (state.chatHistory.length > 40) state.chatHistory = state.chatHistory.slice(-40);
  return reply;
}

// ── MARKDOWN → HTML ───────────────────────────────────────────────
function simpleMarkdownToHtml(md) {
  return md
    .replace(/### (.+)/g, '<h4>$1</h4>')
    .replace(/## (.+)/g,  '<h4>$1</h4>')
    .replace(/# (.+)/g,   '<h4>$1</h4>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g,     '<em>$1</em>')
    .replace(/^- (.+)/gm, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/gs, '<ul>$1</ul>')
    .replace(/\n\n/g, '<br/>')
    .replace(/```[\s\S]*?```/g, '');
}

// ── TAB SWITCHING ─────────────────────────────────────────────────
function switchTab(tabName) {
  document.querySelectorAll('.tab-section').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
  const section = document.getElementById(`tab-${tabName}`);
  if (section) section.classList.add('active');
  const navBtn = document.querySelector(`.nav-btn[data-tab="${tabName}"]`);
  if (navBtn) navBtn.classList.add('active');
  const fab = document.getElementById('fab-chat');
  if (fab) fab.style.display = tabName === 'chat' ? 'none' : 'flex';
  if (tabName === 'dashboard') updateDashboard();
  if (tabName === 'chat') {
    document.getElementById('chat-badge').style.display = 'none';
    setTimeout(() => scrollChatToBottom(), 80);
  }
}

// ── DASHBOARD ─────────────────────────────────────────────────────
function updateDashboard() {
  const totalKcal = state.meals.reduce((s, m) => s + m.kcal, 0);
  const totalProt = state.meals.reduce((s, m) => s + m.protein, 0);
  const totalCarb = state.meals.reduce((s, m) => s + m.carb, 0);
  const totalFat  = state.meals.reduce((s, m) => s + m.fat, 0);
  const burned    = Math.round(state.steps * 0.04 + state.squats * 0.5 + state.meditationSec * 0.05);
  const left      = Math.max(0, CALORIE_GOAL - totalKcal + burned);

  setText('dash-cal-consumed', totalKcal.toLocaleString());
  setText('dash-cal-goal',     CALORIE_GOAL.toLocaleString());
  setText('dash-cal-burned',   burned.toLocaleString());
  setText('dash-cal-left',     left.toLocaleString());

  setRing('ring-cal',  totalKcal, CALORIE_GOAL, 52);
  setRing('ring-prot', totalProt, PROTEIN_GOAL, 40);

  setText('dash-prot', `${Math.round(totalProt)}g / ${PROTEIN_GOAL}g`);
  setText('dash-carb', `${Math.round(totalCarb)}g / ${CARB_GOAL}g`);
  setText('dash-fat',  `${Math.round(totalFat)}g / ${FAT_GOAL}g`);
  setBarWidth('bar-prot', totalProt, PROTEIN_GOAL);
  setBarWidth('bar-carb', totalCarb, CARB_GOAL);
  setBarWidth('bar-fat',  totalFat,  FAT_GOAL);

  setText('dash-steps',    state.steps.toLocaleString());
  setText('dash-water',    state.water);
  setText('dash-sleep',    `${state.sleep}h`);
  setText('dash-meditate', `${Math.round(state.meditationSec / 60)}m`);

  renderMealsList('meals-list', state.meals);
  updateWeeklyCalories(totalKcal);
  renderWeekChart();

  const h = new Date().getHours();
  setText('greeting-time', h < 12 ? 'morning' : h < 17 ? 'afternoon' : 'evening');
}

function setRing(id, val, max, r) {
  const el = document.getElementById(id);
  if (!el) return;
  const circ = 2 * Math.PI * r;
  el.setAttribute('stroke-dasharray', `${Math.min(val / max, 1) * circ} ${circ}`);
  el.setAttribute('stroke-dashoffset', '0');
}

function setBarWidth(id, val, max) {
  const el = document.getElementById(id);
  if (el) el.style.width = `${Math.min(100, (val / max) * 100)}%`;
}

function setText(id, val) {
  const el = document.getElementById(id);
  if (el) el.textContent = val;
}

function updateWeeklyCalories(todayKcal) {
  state.weeklyCalories[state.today] = todayKcal;
}

function getLast7Days() {
  const days = [];
  for (let i = 6; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    days.push(d.toISOString().slice(0, 10));
  }
  return days;
}

function renderWeekChart() {
  const chart = document.getElementById('week-chart');
  if (!chart) return;
  chart.innerHTML = '';
  const days = getLast7Days();
  const maxKcal = Math.max(...days.map(d => state.weeklyCalories[d] || 0), CALORIE_GOAL);
  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  days.forEach(dateStr => {
    const kcal = state.weeklyCalories[dateStr] || 0;
    const pct  = maxKcal > 0 ? (kcal / maxKcal) * 100 : 0;
    const isToday = dateStr === state.today;
    const dow = new Date(dateStr).getDay();
    const col = document.createElement('div');
    col.className = 'wc-col';
    col.innerHTML = `
      <div class="wc-bar-wrap">
        <div class="wc-bar ${isToday ? 'today' : ''}" style="height:${Math.max(pct, 3)}%" title="${kcal} kcal"></div>
      </div>
      <div class="wc-day">${dayNames[dow]}</div>`;
    chart.appendChild(col);
  });
}

function renderMealsList(containerId, meals) {
  const container = document.getElementById(containerId);
  if (!container) return;
  if (meals.length === 0) {
    container.innerHTML = `<div class="empty-state">
      <span class="material-icons-round">no_meals</span>
      <p>No meals logged yet.<br>Tap <strong>+ Add</strong> to analyze food.</p>
    </div>`;
    return;
  }
  container.innerHTML = meals.map((m, i) => `
    <div class="meal-item">
      <div class="meal-thumb" style="background:${scoreToColor(m.score)}22">
        <span class="material-icons-round" style="color:${scoreToColor(m.score)};font-size:20px">${m.icon_name || 'restaurant'}</span>
      </div>
      <div class="meal-info">
        <div class="meal-name">${escHtml(m.name)}</div>
        <div class="meal-sub">${m.protein}g protein · ${m.carb}g carbs · ${m.fat}g fat</div>
      </div>
      <div class="meal-kcal">${m.kcal} kcal</div>
      <button onclick="removeMeal(${i})" style="background:none;border:none;cursor:pointer;color:var(--text-30);padding:4px" title="Remove">
        <span class="material-icons-round" style="font-size:16px">close</span>
      </button>
    </div>`).join('');
}

function scoreToColor(score) {
  return { A: '#10b981', B: '#22c55e', C: '#f97316', D: '#fb923c', F: '#ef4444' }[score] || '#6366f1';
}

// ── NUTRITION TAB ─────────────────────────────────────────────────
function setupNutritionTab() {
  const btnOpenCam = document.getElementById('btn-open-camera');
  const btnSnap    = document.getElementById('btn-snap');
  const btnReset   = document.getElementById('btn-reset-camera');
  const btnUpload  = document.getElementById('btn-upload-photo');
  const fileInput  = document.getElementById('file-input');
  const cameraFeed = document.getElementById('camera-feed');
  const snapCanvas = document.getElementById('snapshot-canvas');
  const snapPrev   = document.getElementById('snapshot-preview');
  const camOverlay = document.getElementById('camera-overlay');

  btnOpenCam.addEventListener('click', async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
      state.cameraStream = stream;
      cameraFeed.srcObject = stream;
      cameraFeed.style.display = 'block';
      snapPrev.style.display = 'none';
      camOverlay.style.display = 'none'; // FIX: use display, not classList
      btnOpenCam.style.display = 'none';
      btnSnap.style.display = 'inline-flex';
      btnReset.style.display = 'inline-flex';
      btnUpload.style.display = 'none';
    } catch (err) {
      showToast('Camera unavailable. Please upload a photo instead.');
    }
  });

  btnSnap.addEventListener('click', () => {
    const ctx = snapCanvas.getContext('2d');
    snapCanvas.width  = cameraFeed.videoWidth;
    snapCanvas.height = cameraFeed.videoHeight;
    ctx.drawImage(cameraFeed, 0, 0);
    const dataUrl = snapCanvas.toDataURL('image/jpeg', 0.85);
    state.snapshotBase64 = dataUrl.split(',')[1];
    state.snapshotMime   = 'image/jpeg';
    snapPrev.src = dataUrl;
    snapPrev.style.display = 'block';
    cameraFeed.style.display = 'none';
    // FIX: show overlay with updated message using display flex
    camOverlay.style.display = 'flex';
    camOverlay.innerHTML = '<span class="material-icons-round camera-icon-big" style="color:var(--green)">check_circle</span><p>Photo captured! Click Analyze.</p>';
    stopCamera();
    btnSnap.style.display = 'none';
  });

  btnReset.addEventListener('click', resetCameraState);

  document.getElementById('camera-zone').addEventListener('click', () => {
    if (!state.cameraStream && !state.snapshotBase64) btnOpenCam.click();
  });

  btnUpload.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => {
      const dataUrl = ev.target.result;
      state.snapshotBase64 = dataUrl.split(',')[1];
      state.snapshotMime   = file.type || 'image/jpeg';
      snapPrev.src = dataUrl;
      snapPrev.style.display = 'block';
      cameraFeed.style.display = 'none';
      camOverlay.style.display = 'none';
      btnReset.style.display = 'inline-flex';
      btnUpload.style.display = 'none';
      btnOpenCam.style.display = 'none';
      showToast('Photo uploaded! Click Analyze.');
    };
    reader.readAsDataURL(file);
    // Reset the input so the same file can be selected again
    fileInput.value = '';
  });

  // FIX: Portion chips — set active-chip via JS so default "1 serving" is always correct
  document.querySelectorAll('.portion-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('.portion-chip').forEach(c => c.classList.remove('active-chip'));
      chip.classList.add('active-chip');
      state.portion = parseFloat(chip.dataset.qty);
    });
  });
  // Set default active chip
  const defaultChip = document.querySelector('.portion-chip[data-qty="1"]');
  if (defaultChip) {
    document.querySelectorAll('.portion-chip').forEach(c => c.classList.remove('active-chip'));
    defaultChip.classList.add('active-chip');
  }

  document.getElementById('btn-analyze').addEventListener('click', handleAnalyze);
  document.getElementById('food-text-input').addEventListener('keydown', e => {
    if (e.key === 'Enter') handleAnalyze();
  });
  document.getElementById('btn-log-meal').addEventListener('click', handleLogMeal);
}

function stopCamera() {
  if (state.cameraStream) {
    state.cameraStream.getTracks().forEach(t => t.stop());
    state.cameraStream = null;
  }
}

function resetCameraState() {
  stopCamera();
  state.snapshotBase64 = null;
  state.snapshotMime   = null;
  const cameraFeed = document.getElementById('camera-feed');
  const snapPrev   = document.getElementById('snapshot-preview');
  const camOverlay = document.getElementById('camera-overlay');
  cameraFeed.style.display = 'none';
  snapPrev.style.display   = 'none';
  // FIX: properly show overlay with flex
  camOverlay.style.display = 'flex';
  camOverlay.innerHTML = `<span class="material-icons-round camera-icon-big">photo_camera</span><p>Tap to snap your food</p>`;
  document.getElementById('btn-open-camera').style.display  = 'inline-flex';
  document.getElementById('btn-upload-photo').style.display = 'inline-flex';
  document.getElementById('btn-snap').style.display         = 'none';
  document.getElementById('btn-reset-camera').style.display = 'none';
  document.getElementById('analysis-result').style.display  = 'none';
  document.getElementById('food-text-input').value = '';
  document.getElementById('file-input').value = '';
  window._lastAnalysis = null;
}

async function handleAnalyze() {
  if (!state.apiKey) { showModal(); return; }
  const foodText = document.getElementById('food-text-input').value.trim();
  if (!foodText && !state.snapshotBase64) {
    showToast('Please type a food name or take/upload a photo first.');
    return;
  }
  document.getElementById('analysis-result').style.display  = 'none';
  document.getElementById('analysis-loading').style.display = 'flex';
  try {
    const result = await geminiAnalyzeFood(foodText, state.snapshotBase64, state.snapshotMime, state.portion);
    if (!result) return;
    renderAnalysisResult(result);
    window._lastAnalysis = result;
    const totalKcal = state.meals.reduce((s, m) => s + m.kcal, 0) + result.calories;
    setText('dash-workout-content', `Based on your intake of ~${totalKcal} kcal, try: ${result.burn_workout}`);
  } catch (err) {
    showToast(`Analysis failed: ${err.message}`);
    console.error(err);
  } finally {
    document.getElementById('analysis-loading').style.display = 'none';
  }
}

function renderAnalysisResult(r) {
  const isHealthy = r.is_healthy !== false;
  setText('res-name', r.name || 'Food item');
  document.getElementById('res-icon').textContent = r.icon_name || 'restaurant';
  const badge = document.getElementById('res-score-badge');
  badge.textContent = `Score: ${r.nutrition_score || 'B'}`;
  badge.style.background   = `${scoreToColor(r.nutrition_score)}22`;
  badge.style.color        = scoreToColor(r.nutrition_score);
  badge.style.borderColor  = `${scoreToColor(r.nutrition_score)}55`;
  document.getElementById('res-verdict-icon').innerHTML = isHealthy
    ? `<span class="material-icons-round" style="color:var(--green);font-size:28px">check_circle</span>`
    : `<span class="material-icons-round" style="color:var(--orange);font-size:28px">warning</span>`;
  document.getElementById('res-kcal').textContent    = `${Math.round(r.calories)} kcal`;
  document.getElementById('res-prot').textContent    = `${Math.round(r.protein_g)}g`;
  document.getElementById('res-carb').textContent    = `${Math.round(r.carbs_g)}g`;
  document.getElementById('res-fat').textContent     = `${Math.round(r.fat_g)}g`;
  document.getElementById('res-verdict').textContent = r.health_insight || r.verdict || '';
  document.getElementById('res-fiber').innerHTML    = `<span class="material-icons-round">grass</span> Fiber: ${r.fiber_g || 0}g`;
  document.getElementById('res-sugar').innerHTML    = `<span class="material-icons-round">icecream</span> Sugar: ${r.sugar_g || 0}g`;
  document.getElementById('res-vitamins').innerHTML = `<span class="material-icons-round">medication</span> ${r.vitamins || 'Various'}`;
  document.getElementById('res-workout').textContent = r.burn_workout || '—';
  document.getElementById('analysis-result').style.display = 'block';
}

function handleLogMeal() {
  const r = window._lastAnalysis;
  if (!r) return;
  const meal = {
    name: r.name, icon_name: r.icon_name || 'restaurant',
    kcal: Math.round(r.calories), protein: Math.round(r.protein_g),
    carb: Math.round(r.carbs_g), fat: Math.round(r.fat_g),
    score: r.nutrition_score, verdict: r.verdict,
    time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  };
  state.meals.push(meal);
  const total = state.meals.reduce((s, m) => s + m.kcal, 0);
  setText('nutrition-total-kcal', `${total} kcal`);
  renderMealsList('nutrition-meals-list', state.meals);
  updateDashboard();
  saveState();
  showToast(`${meal.name} logged!`);
  document.getElementById('analysis-result').style.display = 'none';
  document.getElementById('food-text-input').value = '';
  window._lastAnalysis = null;
  resetCameraState();
}

function removeMeal(index) {
  state.meals.splice(index, 1);
  updateDashboard();
  renderMealsList('nutrition-meals-list', state.meals);
  setText('nutrition-total-kcal', `${state.meals.reduce((s, m) => s + m.kcal, 0)} kcal`);
  saveState();
  showToast('Meal removed.');
}

// ── WORKOUT TAB ───────────────────────────────────────────────────
function setupWorkoutTab() {
  document.getElementById('btn-steps-plus').addEventListener('click', () => {
    state.steps = Math.min(state.steps + 500, 99999); updateSteps();
  });
  document.getElementById('btn-steps-minus').addEventListener('click', () => {
    state.steps = Math.max(state.steps - 500, 0); updateSteps();
  });
  document.getElementById('btn-squats-plus').addEventListener('click', () => {
    state.squats = Math.min(state.squats + 1, 999); updateSquats();
    if (state.squats % 10 === 0 && state.squats > 0) {
      state.setsCompleted = Math.min(Math.floor(state.squats / 10), 5);
      updateSetDots();
      showToast(`Set ${state.setsCompleted} complete!`);
    }
  });
  document.getElementById('btn-squats-minus').addEventListener('click', () => {
    state.squats = Math.max(state.squats - 1, 0);
    state.setsCompleted = Math.floor(state.squats / 10);
    updateSquats(); updateSetDots();
  });
  document.querySelectorAll('.set-dot').forEach(dot => {
    dot.addEventListener('click', () => {
      const n = parseInt(dot.dataset.set);
      state.setsCompleted = state.setsCompleted === n ? n - 1 : n;
      updateSetDots();
    });
  });
  document.getElementById('btn-water-add').addEventListener('click', () => {
    if (state.water < WATER_GOAL) { state.water++; updateWater(); saveState(); }
    else showToast('Daily water goal reached!');
  });
  document.getElementById('btn-water-remove').addEventListener('click', () => {
    if (state.water > 0) { state.water--; updateWater(); saveState(); }
  });
  setupMeditationTimer();
  const slider = document.getElementById('sleep-slider');
  slider.value = state.sleep;
  slider.addEventListener('input', () => {
    state.sleep = parseFloat(slider.value);
    const h = Math.floor(state.sleep), m = Math.round((state.sleep - h) * 60);
    setText('sleep-slider-val', `${h}h ${m}m`);
    setText('wk-sleep-pill', `${state.sleep}h / 8h`);
    setText('dash-sleep', `${state.sleep}h`);
    saveState();
  });
  updateSleepDisplay();
  document.querySelectorAll('.quality-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.quality-btn').forEach(b => b.classList.remove('active-quality'));
      btn.classList.add('active-quality');
      state.sleepQuality = btn.dataset.q; saveState();
    });
    if (btn.dataset.q === state.sleepQuality) btn.classList.add('active-quality');
    else btn.classList.remove('active-quality');
  });
  document.getElementById('btn-gen-workout').addEventListener('click', handleGenerateWorkout);
  updateSteps(); updateSquats(); updateWater(); updateSetDots(); updateSleepDisplay();
}

function updateSteps() {
  setText('wk-steps-val',  state.steps.toLocaleString());
  setText('wk-steps-pill', `${state.steps.toLocaleString()} / ${STEPS_GOAL.toLocaleString()}`);
  setText('dash-steps',    state.steps.toLocaleString());
  setBarWidth('bar-steps', state.steps, STEPS_GOAL); saveState();
}
function setSteps(val) { state.steps = val; updateSteps(); }
window.setSteps  = setSteps;
window.removeMeal = removeMeal;

function updateSquats() {
  setText('wk-squats-val',  state.squats);
  setText('wk-squats-pill', `${state.squats} / ${SQUATS_GOAL}`);
  setBarWidth('bar-squats', state.squats, SQUATS_GOAL); saveState();
}

function updateSetDots() {
  document.querySelectorAll('.set-dot').forEach(dot => {
    const n = parseInt(dot.dataset.set);
    dot.classList.toggle('done', n <= state.setsCompleted);
    dot.textContent = n <= state.setsCompleted ? '✓' : '';
  });
}

function updateWater() {
  setText('wk-water-pill', `${state.water} / ${WATER_GOAL} glasses`);
  setText('dash-water', state.water);
  renderWaterGlasses(); updateWaterTip();
}

function renderWaterGlasses() {
  const container = document.getElementById('water-glasses-display');
  if (!container) return;
  container.innerHTML = '';
  for (let i = 0; i < WATER_GOAL; i++) {
    const gl = document.createElement('div');
    gl.className = `water-glass-icon ${i < state.water ? 'filled' : ''}`;
    gl.innerHTML = '<span class="material-icons-round">water_drop</span>';
    gl.title = i < state.water ? 'Drunk' : 'Not yet';
    gl.addEventListener('click', () => { state.water = i < state.water ? i : i + 1; updateWater(); saveState(); });
    container.appendChild(gl);
  }
}

const waterTips = [
  'Start your day with a glass of water — it kickstarts your metabolism.',
  'Water boosts metabolism and reduces fatigue.',
  'Staying hydrated improves focus and performance!',
  'Water flushes toxins and keeps skin clear.',
  'Half your body weight in lbs in oz is a solid daily goal.',
  'Drink a glass before each meal — it aids digestion.',
  'Hydration is the most underrated part of muscle recovery.',
  'Well done! You have hit your daily water goal.',
];
function updateWaterTip() { setText('water-tip-text', waterTips[Math.min(state.water, waterTips.length - 1)]); }

function updateSleepDisplay() {
  const h = Math.floor(state.sleep), m = Math.round((state.sleep - h) * 60);
  setText('sleep-slider-val', `${h}h ${m}m`);
  setText('wk-sleep-pill', `${state.sleep}h / 8h`);
  const slider = document.getElementById('sleep-slider');
  if (slider) slider.value = state.sleep;
}

let medInterval = null;
function setupMeditationTimer() {
  updateMedDisplay();
  document.getElementById('btn-med-start').addEventListener('click', () => {
    if (state.medRunning) return;
    state.medRunning = true;
    medInterval = setInterval(() => {
      state.meditationSec++;
      updateMedDisplay();
      setBarWidth('bar-meditation', state.meditationSec, MED_GOAL);
      setText('wk-med-pill', `${Math.floor(state.meditationSec / 60)}m ${state.meditationSec % 60}s / 10 min`);
      setText('dash-meditate', `${Math.round(state.meditationSec / 60)}m`);
      if (state.meditationSec === MED_GOAL) showToast('Meditation goal reached! Wonderful.');
      saveState();
    }, 1000);
  });
  document.getElementById('btn-med-stop').addEventListener('click', () => {
    state.medRunning = false; clearInterval(medInterval); saveState();
  });
  document.getElementById('btn-med-reset').addEventListener('click', () => {
    state.medRunning = false; clearInterval(medInterval);
    state.meditationSec = 0; updateMedDisplay();
    setBarWidth('bar-meditation', 0, MED_GOAL);
    setText('wk-med-pill', '0 / 10 min'); setText('dash-meditate', '0m'); saveState();
  });
}

function updateMedDisplay() {
  const min = String(Math.floor(state.meditationSec / 60)).padStart(2, '0');
  const sec = String(state.meditationSec % 60).padStart(2, '0');
  setText('med-timer-display', `${min}:${sec}`);
}

async function handleGenerateWorkout() {
  if (!state.apiKey) { showModal(); return; }
  const totalKcal = state.meals.reduce((s, m) => s + m.kcal, 0);
  const content = document.getElementById('workout-plan-content');
  const loading = document.getElementById('workout-plan-loading');
  content.style.display = 'none';
  loading.style.display = 'flex';
  try {
    const plan = await geminiGenerateWorkout(totalKcal, state.meals);
    content.innerHTML = plan || '<p>Could not generate a plan. Please try again.</p>';
    content.style.display = 'block';
  } catch (err) {
    showToast(err.message);
    content.style.display = 'block';
  } finally {
    loading.style.display = 'none';
  }
}

// ── CHAT TAB ──────────────────────────────────────────────────────
function setupChatTab() {
  const input   = document.getElementById('chat-input');
  const btnSend = document.getElementById('btn-send-chat');
  btnSend.addEventListener('click', sendChatMessage);
  input.addEventListener('keydown', e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendChatMessage(); } });
  document.getElementById('btn-clear-chat').addEventListener('click', () => {
    state.chatHistory = [];
    document.getElementById('chat-messages').innerHTML = '';
    appendBotMessage('Chat cleared! Ask me anything about nutrition, hydration, or fitness.');
    saveState();
  });
  document.querySelectorAll('.qp-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.getElementById('chat-input').value = chip.dataset.prompt;
      sendChatMessage();
      document.getElementById('quick-prompts').style.display = 'none';
    });
  });
  if (state.chatHistory.length > 0) {
    state.chatHistory.forEach(turn => {
      if (turn.role === 'user') appendUserMessage(turn.parts[0].text, false);
      else appendBotMessage(turn.parts[0].text, false);
    });
  }
}

async function sendChatMessage() {
  if (!state.apiKey) { showModal(); return; }
  const input = document.getElementById('chat-input');
  const msg = input.value.trim();
  if (!msg) return;
  input.value = '';
  appendUserMessage(msg);
  document.getElementById('quick-prompts').style.display = 'none';
  const typingId = appendTypingIndicator();
  try {
    const reply = await geminiChat(msg);
    removeTypingIndicator(typingId);
    appendBotMessage(reply || 'I could not respond. Please try again.');
    saveState();
    const chatTab = document.getElementById('tab-chat');
    if (!chatTab.classList.contains('active')) {
      document.getElementById('chat-badge').style.display = 'flex';
    }
  } catch (err) {
    removeTypingIndicator(typingId);
    appendBotMessage(`Error: ${err.message}. Please check your API key.`);
  }
}

function appendUserMessage(text, scroll = true) {
  const msgs = document.getElementById('chat-messages');
  const div = document.createElement('div');
  div.className = 'chat-msg user-msg animate-up';
  div.innerHTML = `
    <div class="msg-avatar"><span class="material-icons-round">person</span></div>
    <div class="msg-bubble">${escHtml(text)}</div>`;
  msgs.appendChild(div);
  if (scroll) scrollChatToBottom();
}

function appendBotMessage(text, scroll = true) {
  const msgs = document.getElementById('chat-messages');
  const div = document.createElement('div');
  div.className = 'chat-msg bot-msg animate-up';
  div.innerHTML = `
    <div class="msg-avatar"><span class="material-icons-round">smart_toy</span></div>
    <div class="msg-bubble">${simpleMarkdownToHtml(text)}</div>`;
  msgs.appendChild(div);
  if (scroll) scrollChatToBottom();
}

function appendTypingIndicator() {
  const msgs = document.getElementById('chat-messages');
  const id = 'typing-' + Date.now();
  const div = document.createElement('div');
  div.id = id; div.className = 'chat-msg bot-msg';
  div.innerHTML = `
    <div class="msg-avatar"><span class="material-icons-round">smart_toy</span></div>
    <div class="msg-bubble">
      <div class="typing-indicator">
        <div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div>
      </div>
    </div>`;
  msgs.appendChild(div);
  scrollChatToBottom();
  return id;
}

function removeTypingIndicator(id) {
  const el = document.getElementById(id);
  if (el) el.remove();
}

function scrollChatToBottom() {
  const msgs = document.getElementById('chat-messages');
  if (msgs) msgs.scrollTop = msgs.scrollHeight;
}

// ── MODAL ─────────────────────────────────────────────────────────
function showModal() {
  const modal = document.getElementById('api-key-modal');
  modal.style.display = 'flex';
  const input = document.getElementById('api-key-input');
  input.value = state.apiKey;
  setTimeout(() => input.focus(), 100);
}
function hideModal() { document.getElementById('api-key-modal').style.display = 'none'; }

function setupModal() {
  document.getElementById('btn-api-key').addEventListener('click', showModal);
  document.getElementById('btn-modal-cancel').addEventListener('click', hideModal);
  document.getElementById('api-key-modal').addEventListener('click', e => {
    if (e.target === e.currentTarget) hideModal();
  });
  document.getElementById('btn-modal-save').addEventListener('click', () => {
    const key = document.getElementById('api-key-input').value.trim();
    if (!key) { showToast('Please enter a valid API key.'); return; }
    state.apiKey = key; saveState(); updateApiKeyStatus(); hideModal();
    showToast('API key saved! You are all set.');
  });
}

// ── TOAST ─────────────────────────────────────────────────────────
let toastTimer = null;
function showToast(msg) {
  const toast = document.getElementById('toast');
  toast.textContent = msg;
  toast.style.display = 'block';
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { toast.style.display = 'none'; }, 3200);
}

// ── HEADER ────────────────────────────────────────────────────────
function setupHeader() {
  const now = new Date();
  document.getElementById('header-date').textContent = now.toLocaleDateString('en-US', {
    weekday: 'long', month: 'short', day: 'numeric'
  });
}

// ── UTILITY ───────────────────────────────────────────────────────
function escHtml(str) {
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function injectSvgDefs() {
  const svg = document.querySelector('.calorie-ring');
  if (!svg) return;
  const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
  defs.innerHTML = `<linearGradient id="orangeGrad" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%"   stop-color="#f97316"/>
    <stop offset="100%" stop-color="#fb923c"/>
  </linearGradient>`;
  svg.prepend(defs);
}

function updateApiKeyStatus() {
  const hasKey = !!state.apiKey;
  document.querySelectorAll('.api-key-warning').forEach(b => {
    b.style.display = hasKey ? 'none' : 'flex';
  });
}

function initRings() {
  ['ring-cal', 'ring-prot'].forEach(id => {
    const el = document.getElementById(id);
    if (el) {
      const r = id === 'ring-cal' ? 52 : 40;
      el.setAttribute('stroke-dasharray', `0 ${2 * Math.PI * r}`);
    }
  });
}

// ── BOOT ──────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  loadState();
  updateApiKeyStatus();
  setupHeader();
  injectSvgDefs();
  initRings();
  setupModal();
  setupNutritionTab();
  setupWorkoutTab();
  setupChatTab();

  renderMealsList('nutrition-meals-list', state.meals);
  setText('nutrition-total-kcal', `${state.meals.reduce((s, m) => s + m.kcal, 0)} kcal`);
  renderWaterGlasses();
  updateMedDisplay();
  updateSteps(); updateSquats(); updateSetDots();
  updateWater(); updateSleepDisplay(); updateDashboard();

  document.getElementById('fab-chat').style.display = 'flex';
  document.addEventListener('visibilitychange', () => { if (document.hidden) stopCamera(); });
});
