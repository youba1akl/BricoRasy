const nodemailer = require('nodemailer');

const sendEmail = async (to, subject, text) => {
  // Configurer le transporteur SMTP
  const transporter = nodemailer.createTransport({
    service: 'gmail', // Exemple avec Gmail
    auth: {
      user: process.env.EMAIL_USER, // ton email Gmail
      pass: process.env.EMAIL_PASS, // mot de passe d'application (pas ton vrai mot de passe)
    },
  });

  // Envoyer l'email
  await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to,
    subject,
    text,
  });
};

module.exports = sendEmail;
