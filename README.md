# MindMesh Frontend

This is the frontend application for MindMesh, built with Next.js and React.

## Features

- Modern and responsive user interface
- Real-time chat functionality
- User authentication and authorization
- Profile management
- Interactive mind mapping visualization

## Getting Started

### Prerequisites

- Node.js (v14 or later)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone https://github.com/REDWANE-AIT-OUKAZZAMANE/mindmesh-frontend.git
```

2. Install dependencies:
```bash
npm install
# or
yarn install
```

3. Create a `.env.local` file in the root directory and add the following environment variables:
```
NEXT_PUBLIC_API_URL=http://localhost:8080
```

4. Start the development server:
```bash
npm run dev
# or
yarn dev
```

The application will be available at `http://localhost:3000`.

## Project Structure

- `/components` - Reusable React components
- `/pages` - Next.js pages and API routes
- `/styles` - Global styles and CSS modules
- `/utils` - Utility functions and helpers
- `/public` - Static assets

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
