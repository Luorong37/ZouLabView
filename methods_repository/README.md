# Legacy Global Methods Repository (not used by the current UI)

This folder is retained so earlier files are not deleted or migrated
silently. The current APP does not list or load methods from this folder.

Current user methods are separated by module under:

`user_data/<user>/methods/<module>/`

Every Record writes a complete aggregate to `Record/methods/record_method.json`
and one actual snapshot per module to `Record/methods/modules/`.
