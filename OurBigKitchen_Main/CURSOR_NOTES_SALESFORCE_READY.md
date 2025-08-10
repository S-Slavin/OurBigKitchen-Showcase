# 🚀 CURSOR NOTES: BUILD SALESFORCE-READY FUNCTIONALITY
**For: Our Big Kitchen iOS App**
**Goal: Complete all backend functionality, ready for Salesforce integration**

---

## 🎯 **CURRENT STATUS - WHAT'S DONE**

### ✅ **COMPLETED (UI/UX Layer)**
- **Welcome Slides**: 4 custom welcome slides with animations
- **Authentication UI**: Sign in/sign up forms, navigation
- **Registration Flow**: 5-step process with WWCC integration
- **App Structure**: Navigation, views, basic state management
- **Design System**: Custom buttons, colors, typography

### ❌ **MISSING (Core Functionality)**
- **Real backend services** - All API calls are stubs
- **Data persistence** - No real user accounts or data
- **Business logic** - No actual app functionality
- **Real-time features** - No live data updates

---

## 🔧 **IMMEDIATE TASKS FOR CURSOR**

### **TASK 1: Implement Real Data Models** 
**Priority: CRITICAL**
- Create proper `User` model with all required fields
- Create `VolunteerSession` model for tracking volunteer work
- Create `Event` model for kitchen events and scheduling
- Create `ImpactMetric` model for meal tracking and reporting
- Create `Donor` model for Salesforce integration preparation

### **TASK 2: Build Real Authentication Service**
**Priority: CRITICAL**
- Replace stub `AuthenticationService` with real implementation
- Implement user registration with actual data persistence
- Implement user login with real authentication
- Add password reset functionality
- Add session management and token handling

### **TASK 3: Create Data Persistence Layer**
**Priority: HIGH**
- Implement Core Data models and relationships
- Create data managers for each entity type
- Add offline-first architecture with local storage
- Implement data synchronization primitives

### **TASK 4: Build Core Business Logic**
**Priority: HIGH**
- **Volunteer Management**: Session creation, tracking, completion
- **Meal Tracking**: Real-time meal counting and impact measurement
- **Event Management**: Event creation, scheduling, volunteer signup
- **Impact Reporting**: Real metrics calculation and display

### **TASK 5: Implement Real-Time Features**
**Priority: MEDIUM**
- Live data updates for volunteer sessions
- Real-time impact metrics
- Live event updates and notifications
- Synchronization between multiple users

---

## 🏗️ **ARCHITECTURE REQUIREMENTS**

### **Data Layer**
```swift
// Core Data Models
- User (id, email, name, role, wwccNumber, wwccExpiry, etc.)
- VolunteerSession (id, userId, startTime, endTime, mealsPrepared, etc.)
- Event (id, title, date, maxVolunteers, currentVolunteers, etc.)
- ImpactMetric (id, date, mealsServed, familiesHelped, etc.)
- Donor (id, name, email, donationAmount, etc.)
```

### **Service Layer**
```swift
// Real Services (not stubs)
- UserService: User CRUD operations
- VolunteerService: Session management
- EventService: Event CRUD and management
- ImpactService: Metrics calculation and reporting
- DonorService: Donor management (Salesforce ready)
```

### **View Models**
```swift
// Real ViewModels with actual data
- HomeViewModel: Real dashboard data
- VolunteerViewModel: Real session management
- EventViewModel: Real event data
- ImpactViewModel: Real impact metrics
- ProfileViewModel: Real user profile data
```

---

## 🔌 **SALESFORCE INTEGRATION PREPARATION**

### **Data Structure Alignment**
- Ensure all models match Salesforce object structure
- Add Salesforce-specific fields (Account ID, Contact ID, etc.)
- Prepare for bidirectional data synchronization

### **API Layer Preparation**
- Create `NetworkManager` for HTTP requests
- Implement REST API client structure
- Add authentication headers and session management
- Prepare for OAuth 2.0 integration

### **Error Handling & Retry Logic**
- Implement robust error handling for network failures
- Add retry mechanisms for failed API calls
- Handle offline scenarios gracefully
- Prepare for Salesforce API rate limiting

---

## 📱 **APP FLOW IMPLEMENTATION**

### **Complete User Journey**
1. **Onboarding** → Welcome slides ✅ (DONE)
2. **Authentication** → Sign up/login ✅ (DONE)
3. **Registration** → Complete profile ✅ (DONE)
4. **Main App** → Real functionality needed ❌
5. **Volunteer Work** → Session management needed ❌
6. **Impact Tracking** → Real metrics needed ❌
7. **Events** → Real event management needed ❌

### **Real App Functionality**
- **Home Dashboard**: Live volunteer sessions, today's impact
- **Volunteer Tab**: Start/stop sessions, track meals prepared
- **Events Tab**: View upcoming events, sign up for shifts
- **Impact Tab**: Real-time impact metrics, photo sharing
- **Profile Tab**: User stats, achievements, settings

---

## 🧪 **TESTING REQUIREMENTS**

### **Unit Tests**
- Test all service methods
- Test data models and relationships
- Test business logic calculations
- Test error handling scenarios

### **Integration Tests**
- Test complete user flows
- Test data persistence
- Test offline/online scenarios
- Test data synchronization

### **UI Tests**
- Test all user interactions
- Test navigation flows
- Test form submissions
- Test real-time updates

---

## 📋 **IMPLEMENTATION ORDER**

### **Phase 1: Foundation (Week 1)**
1. Create Core Data models
2. Implement basic data managers
3. Build UserService with real authentication
4. Add basic data persistence

### **Phase 2: Core Features (Week 2)**
1. Implement VolunteerService
2. Build EventService
3. Create ImpactService
4. Add real-time updates

### **Phase 3: Integration Ready (Week 3)**
1. Implement DonorService
2. Add network layer
3. Prepare for Salesforce objects
4. Add comprehensive error handling

### **Phase 4: Polish & Testing (Week 4)**
1. Add unit tests
2. Add integration tests
3. Performance optimization
4. Final testing and bug fixes

---

## 🎯 **SUCCESS CRITERIA**

### **Functional Requirements**
- [ ] Users can create real accounts and login
- [ ] Volunteer sessions are tracked and persisted
- [ ] Events can be created and managed
- [ ] Impact metrics are calculated in real-time
- [ ] All data persists between app launches
- [ ] Offline functionality works properly

### **Technical Requirements**
- [ ] No more stub/TODO code
- [ ] All services have real implementations
- [ ] Data models are properly structured
- [ ] Error handling is robust
- [ ] Performance is optimized
- [ ] Code is production-ready

### **Salesforce Ready**
- [ ] Data models align with Salesforce objects
- [ ] API layer is prepared for external integration
- [ ] Authentication system supports OAuth
- [ ] Data synchronization primitives exist
- [ ] Error handling covers network scenarios

---

## 🚨 **CRITICAL NOTES FOR CURSOR**

### **DO NOT**
- ❌ Create more placeholder/stub code
- ❌ Add more UI without backend functionality
- ❌ Implement complex animations without core features
- ❌ Focus on design over functionality

### **DO**
- ✅ Build real data models and relationships
- ✅ Implement actual business logic
- ✅ Create real services with data persistence
- ✅ Add proper error handling and validation
- ✅ Make everything production-ready
- ✅ Prepare for Salesforce integration

### **PRIORITY ORDER**
1. **Data Layer** - Core Data models and persistence
2. **Service Layer** - Real business logic implementation
3. **Integration Layer** - Network and API preparation
4. **Testing Layer** - Comprehensive testing coverage

---

## 📁 **KEY FILES TO MODIFY**

### **Models** (Create/Update)
- `OurBigKitchen/Models/User.swift`
- `OurBigKitchen/Models/VolunteerSession.swift`
- `OurBigKitchen/Models/Event.swift`
- `OurBigKitchen/Models/ImpactMetric.swift`
- `OurBigKitchen/Models/Donor.swift`

### **Services** (Replace Stubs)
- `OurBigKitchen/Core/Services/AuthenticationService.swift`
- `OurBigKitchen/Core/Services/UserService.swift`
- `OurBigKitchen/Core/Services/VolunteerService.swift`
- `OurBigKitchen/Core/Services/EventService.swift`
- `OurBigKitchen/Core/Services/ImpactService.swift`

### **ViewModels** (Add Real Data)
- `OurBigKitchen/Views/ViewModels/HomeViewModel.swift`
- `OurBigKitchen/Views/ViewModels/VolunteerViewModel.swift`
- `OurBigKitchen/Views/ViewModels/EventViewModel.swift`
- `OurBigKitchen/Views/ViewModels/ImpactViewModel.swift`

---

## 🎯 **FINAL GOAL**

**Transform this beautiful UI shell into a fully functional, production-ready iOS app that:**

1. **Actually works** - No more placeholder functionality
2. **Manages real data** - Users, sessions, events, impact
3. **Provides real value** - Volunteer management, meal tracking
4. **Is ready for Salesforce** - Proper data structure and API layer
5. **Can be deployed** - Tested, optimized, production-ready

**The app should be indistinguishable from a real, working application that users can actually use to manage Our Big Kitchen operations.**

---

**Next Developer: Start with Phase 1 - Foundation. Build the data layer first, then add real services. Make this app actually functional!**
