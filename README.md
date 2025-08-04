### AdvanceApp 책 검색 앱

---

## 아키텍쳐
- ### MVVM

---

## 사용 기술
- ### RxSwift
- ### RxDataSource
- ### Collectionview Compositional Layout

---

## 메모리 Leak 확인
- https://velog.io/@edenkim/TIL-Memory-Leak-확인

---

## 구조

```
AdvanceApp/
├── AdvanceApp/
│   ├── Application/
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   │
│   ├── Common/
│   │   └── NetworkManager.swift
│   │
│   ├── Presentation/
│   │   ├── Model/
│   │   │   ├── Book.swift
│   │   │   └── SectionModel.swift
│   │   │
│   │   ├── View/
│   │   │   ├── BookCell.swift
│   │   │   ├── DetailViewController.swift
│   │   │   ├── ListViewController.swift
│   │   │   ├── RecentBookCell.swift
│   │   │   ├── SearchViewController.swift
│   │   │   └── SectionHeaderView.swift
│   │   │
│   │   └── ViewModel/
│   │       ├── DetailViewModel.swift
│   │       └── SearchViewModel.swift
│   │       └── BookListViewModel.swift ➕
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Info.plist
│   │   ├── LaunchScreen.storyboard
│   │   ├── Secrets.plist
│   │   └── TabController.swift
│
├── Package Dependencies/
│   ├── Kingfisher 8.5.0
│   ├── RxDataSources 5.0.2
│   ├── RxSwift 6.9.0
│   ├── SnapKit 5.7.1
│   └── Then 3.0.0
```
<img width="250" alt="simulator_screenshot_E2E21755-2FB8-407D-82FC-D88CEBF84C93" src="https://github.com/user-attachments/assets/997d49f4-f2d2-4ce9-aa39-26e433cf1e9a" />
<img width="250" alt="Simulator Screenshot - iPhone 16e - 2025-08-04 at 01 14 19" src="https://github.com/user-attachments/assets/931044a5-6b3d-4002-a92c-4c81ffe148e4" />
