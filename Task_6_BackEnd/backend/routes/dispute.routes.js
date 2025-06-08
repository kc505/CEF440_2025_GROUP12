const express = require('express');
const router = express.Router();
const controller = require('../controllers/dispute.controller');

router.post('/', controller.fileDispute);
router.get('/student/:studentId', controller.getDisputesByStudent);
router.patch('/:id', controller.resolveDispute); 

module.exports = router;
