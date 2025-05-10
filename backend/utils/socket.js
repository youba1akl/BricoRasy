const Message = require("../models/message");

let io;

function initSocket(server) {
  const socketIo = require("socket.io")(server, {
    cors: {
      origin: "*", // Lock down in production
      methods: ["GET", "POST"]
    }
  });

  io = socketIo;

  socketIo.on("connection", (socket) => {
    console.log("📡 Client connected:", socket.id);

    // When a user joins a chat
    socket.on("joinChat", async ({ sender, receiver }) => {
      try {
        const messages = await Message.find({
          $or: [
            { sender, receiver },
            { sender: receiver, receiver: sender }
          ]
        }).sort({ timestamp: 1 });

        socket.emit("receivePreviousMessages", messages);
      } catch (err) {
        console.error("❌ Error loading messages:", err.message);
      }
    });

    // When a message is sent
    socket.on("sendMessage", async (data) => {
      console.log("✉️ Message received:", data);

      const { sender, receiver, content, timestamp } = data;

      // Save the message to MongoDB
      const newMessage = new Message({ sender, receiver, content, timestamp });
      await newMessage.save();

      // Emit to all connected clients
      socketIo.emit("receiveMessage", data);
    });

    socket.on("disconnect", () => {
      console.log("❌ Client disconnected:", socket.id);
    });
  });
}

module.exports = { initSocket };
