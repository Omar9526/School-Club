//
//  PaymentWebView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import WebKit

struct PaymentWebView: View {
    let plan: PremiumPlan
    @ObservedObject var viewModel: PaymentViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                WebView(
                    url: generatePaymentURL(),
                    isLoading: $isLoading,
                    onSuccess: handlePaymentSuccess
                )
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Оплата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generatePaymentURL() -> URL {
        // TODO: Реальный URL платёжного шлюза (например, O!Деньги, Элсом, PayBox)
        // Пример: https://pay.schoolclub.kg/checkout?plan=\(plan.id)&amount=\(plan.price)
        
        var components = URLComponents(string: "https://pay.schoolclub.kg/checkout")!
        components.queryItems = [
            URLQueryItem(name: "plan", value: plan.id),
            URLQueryItem(name: "amount", value: String(plan.price)),
            URLQueryItem(name: "title", value: plan.title)
        ]
        
        return components.url ?? URL(string: "https://schoolclub.kg")!
    }
    
    private func handlePaymentSuccess() {
        Task {
            do {
                try await viewModel.upgradeUserToPremium(plan: plan)
                viewModel.showSuccess = true
                dismiss()
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    let onSuccess: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Проверяем callback URL успешной оплаты
            if let url = navigationAction.request.url,
               url.absoluteString.contains("payment_success") {
                parent.onSuccess()
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
}

#Preview {
    PaymentWebView(
        plan: PremiumPlan(
            id: "monthly",
            type: .monthly,
            title: "Ежемесячная",
            price: 299,
            originalPrice: 399,
            duration: "1 месяц",
            features: []
        ),
        viewModel: PaymentViewModel()
    )
}
