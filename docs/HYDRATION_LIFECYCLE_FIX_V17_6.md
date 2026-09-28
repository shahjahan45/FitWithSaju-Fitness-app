# v17.6 Hydration lifecycle fix

Custom hydration and other text-entry nutrition dialogs now use a `DialogRoute`
whose `completed` future is awaited before any SharedPreferences-backed store
mutation triggers a screen rebuild. Flutter's normal popped result can complete
before the reverse transition/overlay teardown is finished; rebuilding the
nutrition screen in that interval could provoke `_dependents.isEmpty` during
InheritedElement deactivation on physical Android devices.

The Hydration card also no longer triggers a duplicate parent `setState()` after
NutritionStore already emits its change notification.
