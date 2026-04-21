import express, { type Request, type Response, type Application } from 'express';
import passport from 'passport';

const app: Application = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(passport.initialize());
app.use(passport.session());

app.get('/', (req: Request, res: Response) => {
    res.send('Hello avec TypeScript !');
});

app.listen(PORT, () => {
    console.log(`Serveur lancé sur http://localhost:${PORT}`);
});
