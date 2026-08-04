# CoreAI Mac

CoreAI Mac is a native macOS application for interacting with locally hosted large language models (LLMs). Built with Swift and SwiftUI, it provides a polished desktop experience for chat, code analysis, and content summarization with real-time streamed responses.

## Overview

The app connects to local LLM backends such as Ollama and offers a streamlined workflow for:

- chatting with local models
- analyzing code snippets or repository content
- summarizing text and responses
- monitoring connection health and model availability

## Tech Stack

- Swift 5
- SwiftUI
- Combine
- macOS-native UI
- Server-Sent Events (SSE) for streaming responses
- MVVM architecture

## Project Structure

- App/: app entry point and dependency wiring
- Components/: reusable SwiftUI UI components
- Models/: request, response, and settings models
- Services/: core application services such as networking and persistence
- ViewModels/: app logic and state management
- Views/: main screens and user flows
- Networking/: API clients and streaming endpoints

## Features

- Native macOS experience with a modern interface
- Local model discovery and connection handling
- Real-time streaming of AI responses
- Dedicated workflows for chat, analysis, and summarization
- Settings and connection monitoring support

## Requirements

- macOS 14+
- Xcode 15+
- Swift 5.9+
- A local LLM backend such as Ollama running on the machine

## Getting Started

1. Clone the repository.
2. Open CoreAI Mac.xcodeproj in Xcode.
3. Build and run the app on macOS.
4. Ensure your local LLM backend is running and available.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
