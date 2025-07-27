# App Store In-App Purchase Setup Guide

## Overview
This guide explains how to set up real in-app purchases for your HorizonFrame app using StoreKit 2.

## 1. App Store Connect Setup

### Create In-App Purchase Products
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** > **In-App Purchases**
4. Create two products:

#### Yearly Subscription
- **Product ID**: `com.horizonframe.yearly`
- **Reference Name**: `HorizonFrame Yearly`
- **Type**: Auto-Renewable Subscription
- **Subscription Group**: Create new group "HorizonFrame Premium"
- **Duration**: 1 Year
- **Price**: Your desired yearly price
- **Free Trial**: 7 days

#### Weekly Subscription  
- **Product ID**: `com.horizonframe.weekly`
- **Reference Name**: `HorizonFrame Weekly`
- **Type**: Auto-Renewable Subscription
- **Subscription Group**: Same as above
- **Duration**: 1 Week
- **Price**: Your desired weekly price
- **Free Trial**: 3 days

### Configure Subscription Group
1. Set the yearly plan as the **highest service level**
2. Configure upgrade/downgrade behavior
3. Add localized descriptions and promotional images

## 2. Xcode Project Configuration

### Add StoreKit Capability
1. In Xcode, select your project
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **In-App Purchase**

### Update Product IDs
In `SubscriptionManager.swift`, update the product IDs to match your App Store Connect setup:

```swift
private let productIDs = [
    "com.horizonframe.yearly",    // Replace with your actual product ID
    "com.horizonframe.weekly"     // Replace with your actual product ID
]
```

## 3. Testing

### Sandbox Testing (Development)
1. **Create Sandbox Test Users**:
   - Go to App Store Connect > Users and Access > Sandbox Testers
   - Create test Apple IDs for testing purchases

2. **Test in Simulator/Device**:
   - Sign out of App Store on device
   - Run your app
   - When prompted for purchase, use sandbox test account
   - Purchases will be free and instant

3. **Test Scenarios**:
   - Successful purchase
   - Cancelled purchase
   - Restore purchases
   - Subscription management

### TestFlight Testing
1. Upload build to TestFlight
2. Enable in-app purchases for TestFlight
3. Test with real users using sandbox environment

## 4. Production Deployment

### Before App Store Release
1. **Test all purchase flows** thoroughly
2. **Implement receipt validation** (recommended for server-side verification)
3. **Add subscription management** links in your app
4. **Test restore purchases** functionality
5. **Ensure compliance** with App Store Review Guidelines

### App Store Review
- Apple will test your in-app purchases
- Ensure your app works without purchases (basic functionality)
- Clearly describe what users get with subscription
- Follow App Store guidelines for subscription apps

## 5. Advanced Features (Optional)

### Server-Side Receipt Validation
For production apps, implement server-side receipt validation:
1. Send receipts to your server
2. Validate with Apple's servers
3. Grant/revoke access based on validation

### Promotional Offers
- Implement promotional pricing
- Win-back offers for lapsed subscribers
- Upgrade incentives

### Analytics
- Track subscription metrics
- Monitor conversion rates
- A/B test pricing strategies

## 6. Code Structure

The current implementation includes:

- **SubscriptionManager**: Handles all StoreKit operations
- **PaywallView**: Beautiful subscription interface
- **UpgradeButton**: Appears in toolbar when not subscribed
- **Product Management**: Automatic product loading and display

## 7. Important Notes

### Development vs Production
- **Development**: Uses Apple's sandbox with fake transactions
- **Production**: Real money transactions with real users
- Always test thoroughly in sandbox before production release

### Subscription Management
- Users can manage subscriptions in iOS Settings > Apple ID > Subscriptions
- Your app should provide links to subscription management
- Handle subscription status changes gracefully

### Privacy
- Follow App Store privacy guidelines
- Clearly communicate what data you collect
- Respect user privacy choices

## 8. Common Issues

### Products Not Loading
- Verify product IDs match App Store Connect exactly
- Ensure products are approved and available
- Check network connectivity

### Purchases Failing
- Verify StoreKit capability is added
- Check sandbox test account setup
- Ensure proper error handling

### Restore Purchases Not Working
- Implement proper restore functionality
- Handle edge cases (multiple devices, family sharing)
- Test with various scenarios

## Next Steps

1. **Set up App Store Connect** with your product IDs
2. **Test in sandbox** with test accounts
3. **Update product IDs** in the code to match your setup
4. **Test thoroughly** before production release
5. **Submit for App Store review**

Remember: In-app purchases are a critical revenue stream, so thorough testing and proper implementation are essential for success.
