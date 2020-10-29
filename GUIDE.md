**Heads up:** Make sure you're on the [latest version](https://github.com/Betterment/uncruft/releases/latest) of `uncruft` before following these instructions!

# Fixing Deprecations

Here's what to do when you encounter a new error caused by a deprecation warning.

#### When *you* wrote the code

If you encounter a deprecation warning in code that you are actively developing, you should adjust your code according to the recommendation in the warning message.

For example, most deprecation warnings will follow this structure:

> DEPRECATION WARNING: Using method_a will no longer work on Rails 5.1. Use method_b instead. (called from my_code at app/models/my_code.rb:21)

Of course, if the recommendation is opaque or nonexistent, you may need to reach out to your teammates, or search online for additional tips related to the specific message you encountered.

#### When you changed something, and nearby code stopped working

Occasionally, when code is modified or refactored, file names and caller information of preexisting pieces of code will change. This may break any deprecations that were already written to your app's ignorefile, and as such will cause existing code to fail in seemingly new ways.

In such a situation, the best course of action is to fix the offending code so that it avoids encountering the deprecation warning altogether. Even though you didn't introduce the failure, by fixing it you will have moved your app that much closer to running on the next Rails version.

#### When the error is coming from a gem

External gems can cause deprecation warnings too, and with `uncruft` they will raise errors like any other code.

Often, errors can be resolved by simply upgrading to a newer version of the gem, but if you're still seeing a deprecation warning on the latest version, consider posting an issue on the gem's issue tracker. Or, even better, once you've identified the issue, you might be the right person to submit a pull request and fix it!

#### When fixing the issue is too costly

As a last resort, and if reworking the offending code (or upgrading the gem) would be prohibitively time-consuming, you may ignore the warning by rerunning the offending test/code with `RECORD_DEPRECATIONS=1` in your environment. (See [the README](https://github.com/Betterment/uncruft#recording-deprecations) for further instructions.)
