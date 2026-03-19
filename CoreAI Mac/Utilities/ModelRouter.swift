import Foundation

struct ModelRoutingDecision {
    let model: String
    let category: ModelRoutingCategory
}

enum ModelRoutingCategory: String {
    case general
    case development

    var displayTitle: String {
        switch self {
        case .general:
            return "General"
        case .development:
            return "Code"
        }
    }
}

enum ModelRouter {
    static let developmentModel = "qwen2.5-coder:7b"
    static let generalModel = "llama3.2:latest"

    static func decideModel(
        for prompt: String,
        availableModels: [ModelInfo],
        fallbackModel: String
    ) -> ModelRoutingDecision {
        let availableNames = Set(availableModels.map(\.name))
        let category = classify(prompt: prompt)

        switch category {
        case .development:
            if availableNames.contains(developmentModel) {
                return ModelRoutingDecision(model: developmentModel, category: .development)
            }
        case .general:
            if availableNames.contains(generalModel) {
                return ModelRoutingDecision(model: generalModel, category: .general)
            }
        }

        return ModelRoutingDecision(model: fallbackModel, category: category)
    }

    static func classify(prompt: String) -> ModelRoutingCategory {
        let normalized = prompt.lowercased()

        let developmentSignals = [
            "code", "function", "class", "struct", "enum", "swift", "xcode", "debug", "bug",
            "compile", "compiler", "stack trace", "refactor", "implement", "algorithm",
            "api", "json", "sql", "regex", "typescript", "javascript", "python", "java",
            "go ", "rust", "terminal", "shell", "bash", "zsh", "fix this", "error:",
            "exception", "unit test", "test case", "framework", "endpoint", "frontend",
            "backend", "database", "schema", "yaml", "toml", "xml", "html", "css"
        ]

        if normalized.contains("```") {
            return .development
        }

        if normalized.contains("{") || normalized.contains("}") || normalized.contains("=>") || normalized.contains("::") {
            return .development
        }

        if developmentSignals.contains(where: { normalized.contains($0) }) {
            return .development
        }

        return .general
    }
}
