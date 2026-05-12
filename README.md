# CoreAI Mac

CoreAI Mac is a native macOS application designed to seamlessly interact with locally hosted Large Language Models (LLMs). Built with Swift and modern Apple frameworks, it provides a highly polished, responsive interface for managing conversations, analyzing code, and streaming LLM responses in real-time.

## Features

- **Local LLM Integration:** Automatically discovers and connects to locally installed LLMs (e.g., via Ollama).
- **Real-Time Streaming:** Robust Server-Sent Events (SSE) parsing for smooth, character-by-character text generation.
- **Modern Native UI:** Built with SwiftUI, featuring dynamic interactions, generating states, and response action controls (Like, Dislike, Copy).
- **Specialized Workflows:** Dedicated views and models for chatting, code analysis, and content summarization.

## Project Structure

The project follows an MVVM (Model-View-ViewModel) architecture:

- `App/`: Application entry point and lifecycle management.
- `Components/`: Reusable UI elements (e.g., `ComposerSurfaceView`, `ConversationSurfaceView`).
- `Models/`: Data structures representing conversations, messages, and model configurations.
- `ViewModels/`: Business logic bridging the models and views (e.g., `ChatViewModel`, `AnalyzeCodeViewModel`, `SummarizeViewModel`).
- `Services/`: Core functionality layers, such as networking and stream parsing.
- `Networking/`: API clients for interacting with the local LLM servers.
- `Views/`: Main screens of the application.

## Requirements

- macOS 14.0+ (or as specified in the Xcode project)
- Xcode 15.0+
- Swift 5.9+
- A local LLM server (like [Ollama](https://ollama.com/)) running on your machine.

## Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   ```
2. **Open the project:**
   Open `CoreAI Mac.xcodeproj` in Xcode.
3. **Build and Run:**
   Select your target Mac and press `Cmd + R` to build and run the application.

## Usage

Ensure your local LLM backend (e.g., Ollama) is active and serving models. CoreAI Mac will attempt to discover available models on launch. Select a model from the settings or chat interface, and begin sending prompts!

## License

Please see the [LICENSE](LICENSE) file for more details.
