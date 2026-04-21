import express, { type Request, type Response, type Application } from 'express';
import authRoutes from './authentication/.routes/authroutes.js';
import { globalLimiter } from './middleware/rateLimit.js'; // Importe ton limiteur

const app: Application = express();
const PORT = process.env.PORT || 3000;

// 1. Sécurité et Proxy (À mettre en haut)
app.set('trust proxy', 1);
app.use(globalLimiter); // Protection contre le spam sur toute l'API

// 2. Parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 3. Routes
app.get('/', (req: Request, res: Response) => {
    res.send('API Automated Nutrition & Fitness Assistant - ON');
});

app.use('/api', authRoutes);

// 4. Lancement
app.listen(PORT, () => {
    console.log(`🚀 Serveur prêt sur : http://localhost:${PORT}`);
});