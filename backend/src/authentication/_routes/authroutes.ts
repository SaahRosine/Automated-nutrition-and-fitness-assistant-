import { Router } from "express";
import { auth } from "../../middleware/auth.js";
import { authLimiter } from "../../middleware/rateLimit.js"
import { signUpController } from "../sign_up/sign-up-controller.js";
import { loginController } from "../login/login_controller.js";
import { UpdateController } from "../update/updateController.js";
import { deleteController } from "../delete/deleteController.js";
import { rotateTokenController } from "../token/rotateToken.js";

const authenticationrouter: Router = Router();

authenticationrouter.post("/sign-up", authLimiter, signUpController);
authenticationrouter.post("/login", authLimiter, loginController);

authenticationrouter.post("/update", auth, authLimiter, UpdateController);
authenticationrouter.post("/delete", auth, authLimiter, deleteController);
authenticationrouter.post("/rotate-token", auth, authLimiter, rotateTokenController);

export default authenticationrouter;
