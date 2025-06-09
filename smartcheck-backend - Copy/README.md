# SmartCheck Backend

Backend implementation for the SmartCheck attendance management system using Node.js, Express.js, and Firebase.

## Features

- Course management (create, enroll, view, delete)
- Session management (create, close, view, delete)
- Authentication and authorization
- Data validation
- Error handling

## Prerequisites

- Node.js (v14 or higher)
- Firebase project with Firestore database
- Firebase Admin SDK credentials

## Setup

1. Clone the repository
2. Install dependencies:
   \`\`\`
   npm install
   \`\`\`
3. Create a `serviceAccountKey.json` file in the root directory with your Firebase Admin SDK credentials
4. Start the server:
   \`\`\`
   npm run dev
   \`\`\`

## API Endpoints

### Course Module

- `POST /courses` - Create a new course
- `POST /courses/:courseId/enroll` - Enroll a student in a course
- `GET /courses/:courseId` - Get course details
- `GET /courses/user/:uid` - Get courses for a specific user
- `DELETE /courses/:courseId` - Delete a course

### Session Management Module

- `POST /sessions` - Create a new attendance session
- `PATCH /sessions/:sessionId/close` - Close an attendance session
- `GET /sessions/course/:courseId` - Get sessions for a course
- `DELETE /sessions/:sessionId` - Delete a session

## Project Structure

\`\`\`
smartcheck-backend/
├── config/
│   └── firebase.js
├── controllers/
│   ├── courseController.js
│   └── sessionController.js
├── middleware/
│   ├── auth.js
│   └── errorHandler.js
├── models/
│   └── firebaseSchema.js
├── routes/
│   ├── authRoutes.js
│   ├── courseRoutes.js
│   └── sessionRoutes.js
├── utils/
│   ├── apiError.js
│   └── validators.js
├── package.json
├── server.js
└── README.md
\`\`\`

## Error Handling

The API uses a centralized error handling mechanism with custom `ApiError` class. All errors are properly formatted and returned with appropriate HTTP status codes.

## Authentication

The API uses Firebase Authentication for user authentication. All protected routes require a valid Firebase ID token in the Authorization header:

\`\`\`
Authorization: Bearer <firebase-id-token>
\`\`\`

## Authorization

Role-based access control is implemented to ensure users can only access resources they have permission for:

- Students can view courses and sessions
- Lecturers can create and manage their own courses and sessions
- Admins have full access to all resources
