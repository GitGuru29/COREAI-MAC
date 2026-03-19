import Foundation

enum ChatResponseModeResolver {
    static func resolve(
        prompt: String,
        history: [ChatConversationMessage]
    ) -> ChatResponseMode {
        let normalized = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if isCodeRequest(normalized) {
            return .code
        }

        if isGuideRequest(normalized) {
            return .guide
        }

        if isFollowUpPrompt(normalized), isRecentConversationCodeOriented(history) {
            return .code
        }

        return .auto
    }

    static func isCodeRequest(_ prompt: String) -> Bool {
        let codeSignals = [
            "code", "snippet", "sample", "scaffold", "implementation", "example app",
            "web app", "api", "class", "component", "function", "write me", "build",
            "generate", "starter", "project", "template", "source code"
        ]

        return codeSignals.contains(where: { prompt.contains($0) })
    }

    static func isGuideRequest(_ prompt: String) -> Bool {
        let guideSignals = [
            "explain", "help", "guide", "steps", "how", "why", "walk me through",
            "what does", "how does", "teach me"
        ]

        return guideSignals.contains(where: { prompt.contains($0) })
    }

    static func isFollowUpPrompt(_ prompt: String) -> Bool {
        let followUps = [
            "go ahead", "continue", "show code", "do it", "yes", "yes please",
            "sure", "for sure", "why not", "okay", "ok", "please continue"
        ]

        return followUps.contains(where: { prompt == $0 || prompt.hasPrefix($0) })
    }

    static func isRecentConversationCodeOriented(_ history: [ChatConversationMessage]) -> Bool {
        let recentContent = history.suffix(4).map { $0.content.lowercased() }.joined(separator: " ")
        return isCodeRequest(recentContent) || recentContent.contains("```") || recentContent.contains("sample")
    }
}
