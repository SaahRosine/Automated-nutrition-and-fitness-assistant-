import { Router } from "express";
import { InstertWorkOutController } from "../in/done/insertController.js";
import { auth } from "../../middleware/auth.js";
import { globalLimiter } from "../../middleware/rateLimit.js";
const workout_router: Router = Router();

workout_router.post("/insert", globalLimiter, auth, InstertWorkOutController);

export default workout_router;
