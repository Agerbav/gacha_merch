# Gacha Merch

A Flutter application for browsing and buying Genshin Impact weapons.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/)
- [MySQL](https://www.mysql.com/)

### Database Setup

1. Make sure your MySQL server is running.
2. Run the `database.sql` script to create the database and tables:
   ```bash
   mysql -u root -p < database.sql
   ```

### Server Setup

1. Navigate to the server directory:
   ```bash
   cd server
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables:
   - Copy `.env` file (already provided with placeholders) and fill in your details:
     - `JWT_SECRET`: A secret key for JWT tokens.
     - `GOOGLE_CLIENT_ID`: Your Google OAuth client ID.
4. **Important**: Run the seed script to populate the database with categories and initial data before starting the server:
   ```bash
   npm run seed
   ```
5. Start the server:
   ```bash
   npm start
   ```
   The server will run on `http://localhost:3000`.

### Flutter Setup

1. Navigate back to the project root.
2. Run the Flutter app on web using port 5000:
   ```bash
   flutter run -d chrome --web-port 5000
   ```

## Project Structure

- `lib/`: Flutter application source code.
- `server/`: Express.js backend source code.
- `database.sql`: MySQL database schema.
