import Foundation

/// The error type used by custom client errors.
public enum RoboClientError: Error {
    case couldNotEncode(Data)
}
