const express = require('express');
const cors = require('cors');
const path = require('path');
const { initDB } = require('./models/db');
const authRoutes = require('./routes/auth');
const savesRoutes = require('./routes/saves');
const leaderboardRoutes = require('./routes/leaderboard');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

initDB();

app.use('/api', authRoutes);
app.use('/api', savesRoutes);
app.use('/api', leaderboardRoutes);

app.listen(PORT, () => {
  console.log(`FE Tactics backend running on http://localhost:${PORT}`);
});
