/// How the list header should be positioned when content is scrolled.
public enum ListHeaderPosition {

    /// The header will scroll up and down with the content.
    case inline

    /// The header will stick to the top of the content when it's scrolled down, and bounce with content when
    /// it's scrolled up (identical to how sticky section headers behave).
    case sticky

    /// The header is always positioned at the top of the visible frame, and does not bounce with the content.
    case fixed
}
