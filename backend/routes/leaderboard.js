const express = require('express');
const { execQuery, execInsert } = require('../models/db');

const router = express.Router();

router.get('/leaderboard', (req, res) => {
  const results = execQuery(`
    SELECT u.username, l.map_name, l.turns, l.created_at
    FROM leaderboard l
    JOIN users u ON l.user_id = u.id
    ORDER BY l.turns ASC
    LIMIT 50
  `);
  res.json(results);
});

router.post('/leaderboard', (req, res) => {
  const { user_id, map_name, turns } = req.body;
  if (!user_id || !map_name || turns == null) {
    return res.status(400).json({ error: 'user_id, map_name, and turns required' });
  }

  execInsert('INSERT INTO leaderboard (user_id, map_name, turns) VALUES (?, ?, ?)', [user_id, map_name, turns]);
  res.json({ recorded: true });
});

module.exports = router;
