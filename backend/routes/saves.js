const express = require('express');
const { execInsert, execQuery, execQueryOne, execRun } = require('../models/db');

const router = express.Router();

router.post('/saves', (req, res) => {
  const { user_id, name, data } = req.body;
  if (!user_id || !name || !data) {
    return res.status(400).json({ error: 'user_id, name, and data required' });
  }

  const existing = execQueryOne('SELECT id FROM saves WHERE user_id = ? AND name = ?', [user_id, name]);
  const dataStr = JSON.stringify(data);

  if (existing) {
    execRun('UPDATE saves SET data = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [dataStr, existing.id]);
    return res.json({ save_id: existing.id, name, updated: true });
  }

  const result = execInsert('INSERT INTO saves (user_id, name, data) VALUES (?, ?, ?)', [user_id, name, dataStr]);
  res.json({ save_id: result.lastInsertRowid, name, created: true });
});

router.get('/saves', (req, res) => {
  const { user_id } = req.query;
  if (!user_id) {
    return res.status(400).json({ error: 'user_id required' });
  }

  const saves = execQuery('SELECT id, name, created_at, updated_at FROM saves WHERE user_id = ? ORDER BY updated_at DESC', [user_id]);
  res.json(saves);
});

router.get('/saves/:id', (req, res) => {
  const save = execQueryOne('SELECT * FROM saves WHERE id = ?', [req.params.id]);
  if (!save) {
    return res.status(404).json({ error: 'Save not found' });
  }

  try {
    save.data = JSON.parse(save.data);
  } catch (e) {
    save.data = {};
  }
  res.json(save);
});

router.delete('/saves/:id', (req, res) => {
  execRun('DELETE FROM saves WHERE id = ?', [req.params.id]);
  res.json({ deleted: true });
});

module.exports = router;
