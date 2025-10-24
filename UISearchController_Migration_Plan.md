# UISearchController Migration Plan for BPLSearchViewController

## Executive Summary

The current implementation uses a manually managed `UISearchBar` combined with an embedded `BPLSearchViewController` (UICollectionViewController) in a container view. This approach requires manual visibility toggling and complex state management. Converting to `UISearchController` would modernize the codebase, leverage Apple's standard patterns, and simplify the integration significantly.

## Current Architecture Analysis

### Current Implementation
- **Search Bar**: Custom UISearchBar created in `BPLMapViewController.setupSearchBar()`
- **Search Results**: `BPLSearchViewController` (UICollectionViewController) embedded in a container view via storyboard
- **Visibility Management**: Manual toggling via `toggleSearchViewController()` method
- **State Management**: Separate tracking of search state, filtered data, and display logic
- **Integration Points**:
  - Custom delegate protocol (`BPLSearchViewControllerDelegate`)
  - Manual visibility/hidden property management
  - Manual data reloading via `reloadData` calls

### Problems with Current Approach
1. **Manual State Management**: Container view visibility is manually toggled, easily leading to inconsistencies
2. **Boilerplate Code**: Manual setup of search bar, header view, container view positioning
3. **Lifecycle Complexity**: Custom lifecycle methods needed to manage visibility and data
4. **UISearchController Features Missing**:
   - No dimming view when search is active
   - No automatic keyboard handling
   - No built-in search suggestions support
   - Manual handling of search bar text changes
5. **Storyboard Complexity**: Container view with embedded segue adds XML complexity
6. **Testing Difficulty**: Harder to test without actual view hierarchy

## UISearchController Benefits

### Why UISearchController?
1. **Standard Apple Pattern**: UISearchController is the modern, recommended approach (iOS 8+)
2. **Automatic Behavior**:
   - Automatic keyboard presentation/dismissal
   - Automatic dimming view when search is active
   - Automatic navigation bar integration
3. **Simplified Integration**: Direct property on view controller, no container views needed
4. **Better Lifecycle**: Delegates handle showing/hiding automatically
5. **Accessibility**: Built-in accessibility features
6. **iPad Support**: Better handling of split view controllers
7. **Cleaner Code**: Less boilerplate, more declarative

## Migration Strategy

### Phase 1: Create UISearchController-Based Search Results Controller
**Location**: Create new file `BPLSearchResultsController.h/m`

**Key Changes**:
- Change from `UICollectionViewController` to `UIViewController`
- Manage a collection view internally
- Implement `UISearchResultsUpdating` protocol
- Remove `BPLSearchViewControllerDelegate` protocol
- Use closure-based callbacks or KVO for selection handling

```objc
@interface BPLSearchResultsController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, copy) void (^didSelectItemAtIndexPath)(NSIndexPath *indexPath);

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;

@end
```

### Phase 2: Refactor BPLSearchViewController
**Location**: `BPLSearchViewController.h/m`

**Changes**:
- Keep as UICollectionViewController for backward compatibility (if needed)
- OR completely replace if embedding is no longer needed

**Key Decisions**:
- Option A: Keep BPLSearchViewController as a standalone controller that can work with UISearchController
- Option B: Rename BPLSearchViewController to BPLSearchResultsController and update all references
- **Recommendation**: Option A (refactor but keep name for minimal impact)

### Phase 3: Update BPLMapViewController
**Location**: `BPLMapViewController.m`

**Changes**:
1. Remove manual search bar creation (`setupSearchBar()`)
2. Remove search bar delegate methods
3. Remove `toggleSearchViewController()` method
4. Remove `reloadData()` method
5. Remove `containerView` IBOutlet
6. Add `UISearchController` property
7. Add `BPLSearchResultsController` property
8. Implement `UISearchControllerDelegate` and `UISearchResultsUpdating` protocols
9. Update storyboard to remove container view

**New Code Structure**:
```objc
@interface BPLMapViewController () <...>

@property (nonatomic) UISearchController *searchController;
@property (nonatomic) BPLSearchResultsController *searchResultsController;

@end

// In viewDidLoad:
self.searchResultsController = [[BPLSearchResultsController alloc] init];
self.searchResultsController.model = self.model;
self.searchResultsController.currentLocation = self.currentLocation;

__weak typeof(self) weakSelf = self;
self.searchResultsController.didSelectItemAtIndexPath = ^(NSIndexPath *indexPath) {
  [weakSelf handleSearchResultSelection:indexPath];
};

self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
self.searchController.searchResultsUpdater = self.searchResultsController;
self.searchController.delegate = self;
self.navigationItem.searchController = self.searchController;
self.definesPresentationContext = YES;
```

### Phase 4: Update Storyboard
**Location**: `Base.lproj/Main.storyboard`

**Changes**:
1. Remove container view from BPLMapViewController
2. Remove embed segue to BPLSearchViewController
3. Remove BPLSearchViewController scene (if only used for embedding)
4. Update layout constraints for remaining views

### Phase 5: Testing & Validation
**Test Points**:
- [ ] Search bar appears in navigation area when view loads
- [ ] Keyboard presents when search bar is tapped
- [ ] Dimming overlay appears when search is active
- [ ] Search filtering works with text input
- [ ] Selection of results navigates correctly
- [ ] Search dismissal returns to map view
- [ ] Rotation and layout changes work correctly
- [ ] iPad split view behavior (if supported)
- [ ] Memory management (no leaks with new lifecycle)

## Implementation Details

### BPLSearchResultsController (New)

Key responsibilities:
```objc
// Conforms to UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating
@interface BPLSearchResultsController : UIViewController

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, copy) void (^didSelectItemAtIndexPath)(NSIndexPath *indexPath);

// Called by UISearchController when search text changes
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;

@end
```

### Modified BPLMapViewController Methods

**Removed Methods**:
- `setupSearchBar()`
- `toggleSearchViewController(BOOL)`
- `reloadData()`
- All `UISearchBarDelegate` methods
- `setupHeaderView()` (partially - keep styling but integrate with navigation)
- `styleHeaderView()` (partially - update for new layout)

**Updated Methods**:
- `viewDidLoad()` - Initialize UISearchController instead of manual setup
- `commonInit()` - Remove searchBar setup
- `filterDataForSearchText()` - Keep logic, call from search results controller
- `navigateToPlacemark()` - Keep logic, update to dismiss search controller
- `searchViewController:didSelectItemAtIndexPath:` - Rename/update handler

**New Methods**:
- Implement `UISearchControllerDelegate` methods for lifecycle handling
- Handle search result selection via closure callback
- Update location/model propagation

### BPLMapViewController Interface Changes

**Remove**:
```objc
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) BPLSearchViewController *searchViewController;
@property (nonatomic) UISearchBar *searchBar;
```

**Add**:
```objc
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) BPLSearchResultsController *searchResultsController;
```

## Backward Compatibility Considerations

### Data Model Compatibility
- `BPLMapViewModel` - No changes needed, fully compatible
- `BPLPlacemark` - No changes needed
- Filtering logic - No changes needed

### API Compatibility
- Keep `BPLSearchViewControllerDelegate` protocol for reference but transition to closure-based callbacks
- Can deprecate custom protocol in favor of standard UISearchController patterns

### Storyboard Considerations
- Old container view approach becomes obsolete
- Navigation bar search controller placement is automatic
- May affect iPad layout (might need to adjust split view controller setup)

## Risk Assessment

### Low Risk
- Data model changes (none needed)
- Filtering logic (remains the same)
- Selection handling (just different callback mechanism)

### Medium Risk
- Storyboard changes (requires careful testing of layouts)
- Navigation bar integration (iOS behavior varies slightly by version)
- Memory management (UISearchController has different lifecycle)

### Mitigation Strategies
1. **Incremental Migration**: Keep old and new code in parallel during transition
2. **Feature Flagging**: Use a conditional flag to toggle between old/new implementation
3. **Comprehensive Testing**: Test on multiple iOS versions (iOS 13, 14, 15, 16+)
4. **Git Branches**: Create feature branch for safe experimentation

## Alternative Approach: Minimal Changes

If full migration is too risky, consider:
1. Keep BPLSearchViewController embedded in container
2. Just replace the manual UISearchBar with UISearchController
3. Gradual refactoring over multiple releases

```objc
// Hybrid approach: UISearchController with embedded controller
self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchViewController];
// ... rest of setup
```

## Timeline & Effort Estimate

| Phase | Estimated Effort | Notes |
|-------|------------------|-------|
| Phase 1: Create new controller | 2-3 hours | Extract logic, test locally |
| Phase 2: Refactor SearchViewController | 1-2 hours | Minimal if Phase 1 done well |
| Phase 3: Update MapViewController | 2-3 hours | Most complex, requires care with lifecycle |
| Phase 4: Storyboard updates | 1 hour | Straightforward but requires testing |
| Phase 5: Testing & bug fixes | 2-3 hours | Device testing, edge cases |
| **Total** | **8-12 hours** | Assumes incremental, careful approach |

## Rollback Plan

If issues arise:
1. Revert storyboard changes first
2. Revert BPLMapViewController changes
3. Remove new controllers
4. Return to embedded container approach

All changes can be reverted cleanly since we're not modifying core data models.

## Success Criteria

✅ All existing functionality preserved
✅ Code is cleaner and more maintainable
✅ Memory leaks eliminated
✅ Keyboard handling automatic
✅ Dimming view works when search active
✅ No crashes on multiple search/dismiss cycles
✅ iPad layout still works (if applicable)
✅ Selection callbacks fire correctly
✅ Rotation/orientation changes work smoothly

## References

- [UISearchController - Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uisearchcontroller)
- [UISearchResultsUpdating - Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uisearchresultsupdating)
- [Modern Search Bar Best Practices - WWDC Videos](https://developer.apple.com/videos/)

## Recommendations

1. **Start with Phase 1 & 2**: Create the new results controller structure first while keeping existing implementation
2. **Create Feature Branch**: Work in `feature/uisearchcontroller-migration` branch
3. **Test Incrementally**: Test each phase before moving to next
4. **Document Changes**: Update any architecture documentation as you go
5. **Consider Phased Rollout**:
   - Phase 1: Land new infrastructure
   - Phase 2: Switch over integration (can be reverted if issues found)
   - Phase 3: Cleanup old code after stabilization period

