import express, { type Request, type Response, type Application } from 'express';
import authRoutes from './authentication/_routes/authroutes.js';
import { globalLimiter } from './middleware/rateLimit.js'; // Importe ton limiteur
import cors from 'cors';
import workout_router from './workout/_routes/routes.js';

const app: Application = express();
const PORT = process.env.PORT || 4000;

// 1. Sécurité et Proxy (À mettre en haut)
app.set('trust proxy', 1);
app.use(cors()); // CORS avant tout le reste
app.use(globalLimiter); // Protection contre le spam sur toute l'API

// 2. Parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 3. Routes
app.get('/', (req: Request, res: Response) => {
    res.send('API Automated Nutrition & Fitness Assistant - ON');
});

// cors() déjà appliqué plus haut

app.use('/api', authRoutes);
app.use('/api/workout', workout_router);

// 4. Lancement
app.listen(Number(PORT), '0.0.0.0', () => {
    console.log(`🚀 Serveur prêt sur : http://localhost:${PORT}`);
    console.log(`📱 Accessible depuis le réseau : http://192.168.1.XXX:${PORT}`);
});