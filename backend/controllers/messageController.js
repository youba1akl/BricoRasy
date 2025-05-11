const Message = require('../models/message');

// POST /api/messages
exports.createMessage = async (req, res) => {
  try {
    const { annonceId, to, content } = req.body;
    // from comes from auth middleware
    const from = req.user._id;

    if (!annonceId || !to || !content) {
      return res.status(400).json({ message: 'Champs manquants' });
    }

    const msg = await Message.create({ annonceId, from, to, content });
    // Optionally populate sender info here...

    // Emit via socket.io
    req.app.get('io').to(to.toString()).emit('newMessage', {
      annonceId,
      from: from.toString(),
      content,
      timestamp: msg.createdAt
    });

    res.status(201).json(msg);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/messages/conversations
// controllers/messageController.js
exports.getConversations = async (req, res) => {
  const userId = req.user._id;
  // group by annonceId + peerId, then pick the latest content
  const raw = await Message.aggregate([
    { $match: { $or: [ { from: userId }, { to: userId } ] } },
    { $sort: { createdAt: -1 } },
    { $group: {
       _id: {
         annonce: "$annonceId",
         peer: { $cond: [ { $eq: ["$from", userId] }, "$to", "$from" ] }
       },
       lastMessage: { $first: "$content" }
    }},
    { $lookup: {
       from: "users",
       localField: "_id.peer",
       foreignField: "_id",
       as: "peerInfo"
    }},
    { $unwind: "$peerInfo" },
    { $project: {
       annonceId: "$_id.annonce",
       peerId:    "$_id.peer",
       peerName:  "$peerInfo.fullname",
       lastMessage: 1
    }},
  ]);
  res.json(raw);
};


// GET /api/messages/:annonceId/:peerId
exports.getChat = async (req, res) => {
  const { annonceId, peerId } = req.params;
  const userId = req.user._id;
  const msgs = await Message.find({
    annonceId,
    $or: [
      { from: userId, to: peerId },
      { from: peerId, to: userId }
    ]
  }).sort({ createdAt: 1 });
  res.json(msgs);
};
