# SailyTest

A comprehensive test project demonstrating modern iOS development with SwiftUI, The Composable Architecture (TCA), and async/await networking. This project showcases best practices for building scalable, testable iOS applications.

## Features

- **Authentication Flow**: Login with secure credential storage using Keychain
- **Server List**: Display, sort, and filter VPN servers with intelligent caching
- **Modern Architecture**: TCA-based state management with dependency injection
- **Async Networking**: Modern URLSession with async/await and robust 401 handling
- **Offline Support**: Cached server list with cache-first loading strategy
- **Comprehensive Testing**: Full unit test coverage with TCA TestStore
- **Error Handling**: Graceful network error handling with user feedback

## Architecture

### State Management
- **The Composable Architecture (TCA)**: Predictable state management
- **Dependency Injection**: Testable and mockable dependencies
- **Reducer Composition**: Modular feature organization

### Networking
- **Modern URLSession**: Async/await based API calls
- **401 Handling**: Automatic token refresh with retry logic
- **Error Handling**: Graceful fallback to cached data

### Persistence Strategy

For this test project, we use **UserDefaults** for server caching instead of Core Data or SQLite because:

- **Simple Data**: Only server list (20-50 items)
- **No Complex Queries**: Just store/retrieve operations  
- **Test Scope**: Keep implementation lightweight
- **Zero Dependencies**: Built-in Foundation support
- **Fast Access**: Immediate offline capability

#### Cache Strategy
- **Timestamp-based**: 5-minute cache expiry (simple and effective)
- **Cache-first**: Load cached data immediately, refresh in background
- **Offline fallback**: Show cached servers when network unavailable

#### Storage Layer
```
StorageWrapper (UserDefaults) 
    ↓
StorageClient (TCA Dependency)
    ↓  
ServersList Reducer (Cache Integration)
```

For production apps with complex data relationships, consider Core Data or SQLite.

## Dependencies

- **ComposableArchitecture**: State management
- **KeychainWrapper**: Secure credential storage
- **Foundation**: UserDefaults for caching

## Testing

### Comprehensive Test Coverage
- **AppReducer Tests**: App launch scenarios, navigation flow, and credential validation
- **ServersList Tests**: Cache-first loading, server fetching, sorting, error handling
- **Login Tests**: Authentication flow, credential storage, and error scenarios
- **Mock Dependencies**: Testable storage, networking, and keychain layers
- **TCA TestStore**: Full state management testing with action/reducer verification