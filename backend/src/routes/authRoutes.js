const express = require("express");
const {
  register,
  login,
  getCurrentUser,
} = require("../controllers/authController");
const auth = require("../middleware/auth");

const router = express.Router();

// Public routes
router.post("/register", register);
router.post("/login", login);

// Protected routes
router.get("/me", auth, getCurrentUser);

module.exports = router;
