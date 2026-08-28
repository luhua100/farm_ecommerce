# 楚智农购 

一个基于 Flutter 开发的现代化农产品电商移动应用，专为农产品采购和销售打造的综合性平台。

## 📱 应用简介

楚智农购是一款面向农业领域的电商应用，提供农产品浏览、购买、订单管理、营销活动等完整的电商功能，致力于为用户提供便捷的农产品采购体验。

## ✨ 核心功能

### 🏠 主要模块

- **首页 (Home)** - 展示热门商品、推荐产品和营销活动
- **分类浏览 (Category)** - 按照商品分类快速查找所需农产品
- **商品详情 (Product)** - 查看商品详细信息、图片、价格和规格
- **搜索 (Search)** - 强大的搜索功能，快速定位目标商品
- **购物车 (Cart)** - 管理待购买商品，批量结算
- **订单管理 (Order)** - 查看订单状态、历史订单和物流信息
- **个人中心 (Mine)** - 个人信息、设置和账户管理
- **地址管理 (Address)** - 管理收货地址，快速选择配送地点
- **售后服务 (After Sales)** - 退换货申请和售后处理
- **营销活动 (Marketing)** - 查看优惠活动、促销信息
- **消息中心 (Message)** - 接收系统通知、订单消息
- **客服支持 (Support)** - 在线客服和帮助文档

### 🔐 用户功能

- **用户登录/注册** - 支持多种登录方式
- **微信集成** - 支持微信登录和微信支付
- **个人信息管理** - 完善的用户资料管理功能

## 🔧 技术栈

### 核心框架

- **Flutter SDK** `^3.9.2` - 跨平台移动应用开发框架
- **Dart** - 编程语言

### 主要依赖插件

#### 状态管理 & 路由
- **get** `^4.6.6` - 状态管理、路由管理和依赖注入

#### 网络 & 数据
- **dio** `^5.7.0` - 强大的 HTTP 网络请求库
- **shared_preferences** `^2.3.2` - 本地数据持久化存储
- **logger** `^2.0.2+1` - 日志记录工具

#### UI 组件
- **flutter_easyloading** `^3.0.5` - 优雅的加载动画和提示框
- **carousel_slider** `^5.1.2` - 轮播图组件
- **cached_network_image** `^3.4.1` - 网络图片缓存加载
- **flutter_cache_manager** `^3.4.1` - 缓存管理器
- **webview_flutter** `^4.13.1` - WebView 支持

#### 媒体 & 文件
- **image_picker** `^1.1.2` - 图片选择和拍照功能
- **docx_file_viewer** `^1.0.2` - Word 文档查看器

#### 第三方集成
- **fluwx** `^5.7.7` - 微信 SDK 集成（登录、分享、支付）
- **url_launcher** `^6.3.0` - 打开外部链接和应用

#### 应用启动
- **flutter_native_splash** `^2.4.7` - 原生启动屏幕配置

### 开发工具

- **flutter_lints** `^5.0.0` - Flutter 代码规范检查
- **flutter_launcher_icons** `^0.14.4` - 应用图标生成器

## 🎨 应用配置

### 启动屏幕

- 背景色：`#078FED`（品牌蓝色）
- 支持 Android 12+ 新版启动屏幕
- 全屏显示

### 应用图标

- 使用 `assets/images/icon.png` 作为应用图标
- 自动生成各尺寸图标

## 📦 项目结构

```
lib/
├── core/           # 核心功能（存储、主题、网络等）
├── data/           # 数据层（模型、仓库、API）
├── modules/        # 功能模块
│   ├── home/       # 首页
│   ├── category/   # 分类
│   ├── product/    # 商品详情
│   ├── cart/       # 购物车
│   ├── order/      # 订单
│   ├── mine/       # 个人中心
│   ├── login/      # 登录
│   ├── address/    # 地址管理
│   ├── after_sales/# 售后服务
│   ├── marketing/  # 营销活动
│   ├── message/    # 消息中心
│   ├── search/     # 搜索
│   ├── support/    # 客服支持
│   └── splash/     # 启动页
├── routes/         # 路由配置
└── shared/         # 共享组件和工具
```

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.9.2 或更高版本
- Dart SDK 3.9.2 或更高版本
- Android Studio / VS Code
- Android SDK（Android 开发）

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd farm_buy
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置微信 SDK**
   
   应用启动时可以通过编译参数提前注册微信 SDK。请确保在 Android 项目中正确配置微信 AppID。

4. **生成启动屏幕**
   ```bash
   dart run flutter_native_splash:create
   ```

5. **生成应用图标**
   ```bash
   dart run flutter_launcher_icons
   ```

6. **运行应用**
   ```bash
   flutter run
   ```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 🔑 功能特色

- ✅ **响应式设计** - 适配不同尺寸的移动设备
- ✅ **图片缓存** - 优化图片加载性能，减少流量消耗
- ✅ **离线存储** - 支持本地数据缓存
- ✅ **微信生态** - 深度集成微信登录和支付
- ✅ **优雅的加载动画** - 提升用户体验
- ✅ **完整的电商流程** - 从浏览到支付的完整购物体验

## 📄 许可证

本项目为私有项目，不对外发布。

## 👥 联系方式

如有问题或建议，请联系开发团队。

---

**版本号**: 1.0.0+1  
**最后更新**: 2026年




