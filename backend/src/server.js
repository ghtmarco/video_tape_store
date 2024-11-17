const express = require("express");
const cors = require("cors");
require("dotenv").config();
const db = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const videoTapeRoutes = require("./routes/videoTapeRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/videotapes", videoTapeRoutes);

// Test route
app.get("/api/test", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT 1 + 1 AS result");
    res.json({
      message: "Backend is working!",
      dbConnection: "Database connected successfully",
      result: rows[0].result,
    });
  } catch (error) {
    res.status(500).json({
      message: "Error connecting to database",
      error: error.message,
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
