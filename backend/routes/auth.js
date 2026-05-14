const express = require('express');
const bcrypt = require('bcryptjs');
const { execInsert, execQueryOne } = require('../models/db');

const router = express.Router();

router.post('/register', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password required' });
  }
  if (password.length < 3) {
    return res.status(400).json({ error: 'Password too short' });
  }

  const existing = execQueryOne('SELECT id FROM users WHERE username = ?', [username]);
  if (existing) {
    return res.status(409).json({ error: 'Username already exists' });
  }

  const hash = bcrypt.hashSync(password, 10);
  const result = execInsert('INSERT INTO users (username, password_hash) VALUES (?, ?)', [username, hash]);
  res.json({ user_id: result.lastInsertRowid, username });
});

router.post('/login', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password required' });
  }

  const user = execQueryOne('SELECT * FROM users WHERE username = ?', [username]);
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  if (!bcrypt.compareSync(password, user.password_hash)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  res.json({ user_id: user.id, username: user.username });
});

module.exports = router;
