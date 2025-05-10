const Message = require('../models/message');

exports.getMessages = async (req, res) => {
  const { userId, contactId } = req.params;
  try {
    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: contactId },
        { senderId: contactId, receiverId: userId }
      ]
    }).sort({ timestamp: 1 });

    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
};
