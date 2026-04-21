import rateLimit from 'express-rate-limit';

// Limiteur général pour toutes les routes
export const globalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // Fenêtre de 15 minutes
    max: 100, // Limite chaque IP à 100 requêtes par fenêtre
    standardHeaders: true, // Retourne les infos de limite dans les headers `RateLimit-*`
    legacyHeaders: false, // Désactive les headers `X-RateLimit-*`
    message: { success: false, message: "Trop de requêtes, réessayez plus tard." }
});

// Limiteur strict pour l'authentification (Brute Force)
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // Seulement 5 tentatives par 15 minutes (login/sign-up)
    message: { success: false, message: "Trop de tentatives de connexion." }
});
