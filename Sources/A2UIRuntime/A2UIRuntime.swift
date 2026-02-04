import Foundation

/// Convenience exports for consumers.
public enum A2UIRuntime {
    public static func defaultEngine() -> A2UIEngine {
        let agent = RuleBasedIncidentAgent()
        let executor = LocalJSONTaskExecutor()
        return A2UIEngine(agent: agent, executor: executor)
    }
}
