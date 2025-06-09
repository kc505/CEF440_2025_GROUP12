const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/',(req, res) =>{
res.status(200).json({message:"Welcome to the SmartCheck Backend"})
})

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`SmartCheck backend running on port ${PORT}`);
});


module.exports = app;
