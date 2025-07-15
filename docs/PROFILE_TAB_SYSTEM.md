# Profile Tab System - SETPocket App

## Overview
Hệ thống Profile Tab đã được thiết kế lại để cung cấp trải nghiệm người dùng linh hoạt và thuận tiện hơn.

## Key Components

### 1. ProfileTabService
- Quản lý state của 3 Profile Tabs
- Lưu trữ trạng thái vào SharedPreferences
- Tự động restore khi khởi động lại app

### 2. Mobile Layout
- **Bottom Navigation Bar**: 5 tabs bao gồm:
  - Tab 1, Tab 2, Tab 3 (Profile tabs)
  - Routine Button (nhô lên ở giữa)
  - Settings tab (bên phải)
- **Dynamic AppBar Title**: Thay đổi theo tool hiện tại của tab
- **State Persistence**: Mỗi tab lưu trạng thái riêng

### 3. Desktop Layout  
- **Sidebar**: Tool selection + Profile Section ở dưới
- **Profile Section**: 
  - Dòng 1: 3 Profile Tab widgets
  - Dòng 2: Routine widget + Settings widget
- **Main Area**: Hiển thị tool của tab hiện tại

### 4. Profile Tool Selection Screen
- Hiển thị danh sách tools có sẵn
- Tự động cập nhật tab state khi chọn tool
- Tích hợp với ToolVisibilityService

## Features

### Tab Profile System
1. **3 Tab Profiles**: Mỗi tab lưu một tool riêng
2. **Dynamic Icons & Titles**: Icon và tên tab thay đổi theo tool
3. **Persistent State**: Trạng thái được lưu và restore
4. **Easy Navigation**: Chuyển đổi tab dễ dàng

### Settings Integration
- **Mobile**: Settings button trên bottom nav
- **Desktop**: Settings widget trong Profile Section
- Không còn Settings trong sidebar chính

### Routine Hub
- **Placeholder** cho tính năng workflow automation
- **Mobile**: Navigation từ bottom nav center button
- **Desktop**: Widget trong Profile Section

## Technical Implementation

### State Management
```dart
ProfileTabService.instance.updateTabTool(
  tabIndex: 0,
  toolId: 'textTemplate',
  toolTitle: 'Text Templates',
  icon: Icons.description,
  iconColor: Colors.blue,
  toolWidget: TemplateListScreen(),
);
```

### Navigation Pattern
- **Mobile**: Traditional Flutter navigation
- **Desktop**: Widget replacement trong main area
- **Tab switching**: ProfileTabService manages all navigation

### Storage
- SharedPreferences để lưu tab states
- JSON serialization cho ProfileTab objects
- Automatic initialization và recovery

## Benefits

1. **User Experience**:
   - Workflow persistence
   - Quick tool switching
   - Intuitive navigation

2. **Productivity**:
   - Multi-tasking support
   - Context preservation
   - Reduced navigation overhead

3. **Flexibility**:
   - Customizable tab assignment
   - Dynamic tool loading
   - Cross-platform consistency
