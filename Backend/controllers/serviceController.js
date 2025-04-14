const Service = require('../models/Service');

exports.createService = async (req, res) => {
  const { title, description, price } = req.body;
  try {
    const service = await Service.create({
      title,
      description,
      price,
      provider: req.user.id,
    });
    res.status(201).json(service);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
};

exports.getServices = async (req, res) => {
  const services = await Service.find().populate('provider', 'name');
  res.json(services);
};
