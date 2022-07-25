//
//  SectionPosition.swift
//  ListableUI
//
//  Created by Ian Luo on 3/10/21.
//

/// Specifies the supplementary views and / or items based on position within a `Section`.
///
public enum SectionPosition: Equatable {
    /// Represents the header and / or first item(s) within a section.
    case top

    /// Represents the footer and / or last item(s) within a section.
    case bottom
}
