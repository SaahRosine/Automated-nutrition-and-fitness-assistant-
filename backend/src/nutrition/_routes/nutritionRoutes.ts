import { Router } from 'express';
import multer from 'multer';
import { NutritionController } from '../nutritionController.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });
const nutritionController = new NutritionController();

router.post('/analyze-food', upload.single('image'), (req, res) => nutritionController.analyzeFood(req, res));
router.post('/generate-workout', (req, res) => nutritionController.generateWorkout(req, res));
router.post('/chat', (req, res) => nutritionController.chat(req, res));

export default router;
