import Foundation

public enum IssueTrackerPreferences {
    public static var jiraDomain: String {
        get { UserDefaults.standard.string(forKey: "kouen.jira.domain") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "kouen.jira.domain") }
    }

    public static var jiraEmail: String {
        get { UserDefaults.standard.string(forKey: "kouen.jira.email") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "kouen.jira.email") }
    }

    public static var azureOrganization: String {
        get { UserDefaults.standard.string(forKey: "kouen.azure.organization") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "kouen.azure.organization") }
    }
}
