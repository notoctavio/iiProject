const mongoose = require('mongoose');

const connectDB = async (uri) => {
    try {
        if (mongoose.connection.readyState === 1) {
            console.log('MongoDB already connected');
            return;
        }

        const conn = await mongoose.connect(uri || 'mongodb://localhost:27017/bugetlyDB', {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`MongoDB connection error: ${error.message}`);
        if (process.env.NODE_ENV !== 'test') {
            process.exit(1);
        }
    }
};

// uri ar trebui să fie connection string-ul din MongoDB Atlas, setat în .env ca MONGODB_URI

module.exports = connectDB; 