//
//  BackendHealthManager.swift
//  Attunetion
//
//  Manages backend health checking and availability status
//

import Foundation
import Combine

/// Manages backend health status and availability checks
@MainActor
class BackendHealthManager: ObservableObject {
    static let shared = BackendHealthManager()
    
    @Published private(set) var isBackendAvailable: Bool = false
    
    private let healthCheckKey = "BackendHealthCheckTimestamp"
    private let backendAvailableKey = "BackendAvailable"
    
    // Cache health check for 5 minutes to avoid excessive checks
    private let healthCheckCacheDuration: TimeInterval = 300 // 5 minutes
    
    private init() {
        // Load cached status on init
        loadCachedStatus()
    }
    
    /// Check backend health and update availability status
    /// This should be called once on app launch
    func checkBackendHealth() async {
        // Check if we have a recent cached result
        if let lastCheck = UserDefaults.standard.object(forKey: healthCheckKey) as? Date,
           Date().timeIntervalSince(lastCheck) < healthCheckCacheDuration {
            // Use cached result
            isBackendAvailable = UserDefaults.standard.bool(forKey: backendAvailableKey)
            return
        }
        
        // Perform health check
        do {
            let isHealthy = try await APIClient.shared.checkHealth()
            isBackendAvailable = isHealthy
            
            // Cache the result
            UserDefaults.standard.set(Date(), forKey: healthCheckKey)
            UserDefaults.standard.set(isHealthy, forKey: backendAvailableKey)
        } catch {
            // Backend is not available if health check fails
            isBackendAvailable = false
            
            // Cache the failure (with shorter cache duration for failures)
            UserDefaults.standard.set(Date(), forKey: healthCheckKey)
            UserDefaults.standard.set(false, forKey: backendAvailableKey)
            
            print("Backend health check failed: \(error.localizedDescription)")
        }
    }
    
    /// Load cached backend availability status
    private func loadCachedStatus() {
        isBackendAvailable = UserDefaults.standard.bool(forKey: backendAvailableKey)
    }
    
    /// Force a fresh health check (ignoring cache)
    func forceHealthCheck() async {
        UserDefaults.standard.removeObject(forKey: healthCheckKey)
        await checkBackendHealth()
    }
}

