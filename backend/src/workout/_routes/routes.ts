import { Router } from "express";
import { InstertWorkOutController } from "../in/done/insertController.js";
import { auth } from "../../middleware/auth.js";
import { globalLimiter } from "../../middleware/rateLimit.js";
import { GetWorkoutController } from "../out/outputController.js";
const workout_router: Router = Router();

workout_router.post("/insert", globalLimiter, auth, InstertWorkOutController);
workout_router.get("/output", globalLimiter, auth, GetWorkoutController);

export default workout_router;
