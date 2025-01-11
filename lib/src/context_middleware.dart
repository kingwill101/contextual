/// A typedef for a function that returns a [Map<String, dynamic>].
/// This type is commonly used as a middleware function in a context-based
/// application architecture, where the middleware function is responsible for
/// providing the necessary context data for the current request or operation.
typedef ContextMiddleware = Map<String, dynamic> Function();
