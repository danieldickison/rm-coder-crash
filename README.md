rm-coder-crash
==============

Demo of a RubyMotion crash.  The DiskCacheEntry object seems to occasionally get deallocated before `-[NSKeyedArchiver unarchiveObjectWithFile:]` returns when the archiving/unarchiving is happening in a serial GCD queue in Obj-C while the RM code is running in a background Dispatch::Queue.  I'm not sure if all of those conditions are necessary, but it seems to be sufficient.

Interestingly, *not* calling `init` from DiskCacheEntry's `initWithCoder:` method fixes the problem (or at least makes it much less frequent).

```
$ rake debug=1 target=6.1
     Build ./build/iPhoneSimulator-6.0-Development
     Build objc
      Link ./build/iPhoneSimulator-6.0-Development/coder_crash.app/coder_crash
    Create ./build/iPhoneSimulator-6.0-Development/coder_crash.app/Info.plist
    Create ./build/iPhoneSimulator-6.0-Development/coder_crash.dSYM
  Simulate ./build/iPhoneSimulator-6.0-Development/coder_crash.app
2014-04-10 01:37:54.175 coder_crash[2194:3d03] unarchived entry <DiskCacheEntry format:8 data:17855 bytes>
2014-04-10 01:37:54.181 coder_crash[2194:3d03] unarchived entry <DiskCacheEntry format:8 data:17855 bytes>
2014-04-10 01:37:54.268 coder_crash[2194:3c03] archived entry <DiskCacheEntry format:6 data:17855 bytes>
2014-04-10 01:37:54.373 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:6 data:17855 bytes>
2014-04-10 01:37:54.503 coder_crash[2194:3c03] archived entry <DiskCacheEntry format:3 data:17855 bytes>
2014-04-10 01:37:54.632 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:3 data:17855 bytes>
2014-04-10 01:37:54.765 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:3 data:17855 bytes>
2014-04-10 01:37:54.908 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:3 data:17855 bytes>
2014-04-10 01:37:54.977 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:3 data:17855 bytes>
[...]
2014-04-10 01:38:44.087 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:1 data:17855 bytes>
2014-04-10 01:38:44.200 coder_crash[2194:3c03] unarchived entry <DiskCacheEntry format:1 data:17855 bytes>
2014-04-10 01:38:44.266 coder_crash[2194:3c03] archived entry <DiskCacheEntry format:4 data:17855 bytes>
2014-04-10 01:38:44.307 coder_crash[2194:3c03] archived entry <DiskCacheEntry format:5 data:17855 bytes>
Executing commands in '/var/folders/j3/6n4txds13kb70hklkw70r2040000gn/T/_simgdbcmds_ios'.
(lldb)  process attach -p 2194
Process 2194 stopped
Executable module set to "/usr/lib/dyld".
Architecture set to: i486-apple-macosx.
(lldb)  command script import /Library/RubyMotion/lldb/lldb.py
(lldb)  breakpoint set --name rb_exc_raise
Breakpoint 1: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.
(lldb)  breakpoint set --name malloc_error_break
Breakpoint 2: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.
(lldb)  continue
Process 2194 resuming
Process 2194 stopped
1 location added to breakpoint 1
1 location added to breakpoint 2
(lldb) bt
* thread #1: tid = 0xfca933, 0x02a697ca libsystem_kernel.dylib`__psynch_cvwait + 10, queue = 'com.apple.main-thread'
  * frame #0: 0x02a697ca libsystem_kernel.dylib`__psynch_cvwait + 10
    frame #1: 0x02b5cd1d libsystem_pthread.dylib`_pthread_cond_wait + 728
    frame #2: 0x02b5ec25 libsystem_pthread.dylib`pthread_cond_timedwait$UNIX2003 + 71
    frame #3: 0x0014e15a coder_crash`rb_thread_wait_for + 234
    frame #4: 0x0009740e coder_crash`rb_f_sleep + 62
    frame #5: 0x00125237 coder_crash`rb_vm_dispatch + 4679
    frame #6: 0x00004f6c coder_crash`vm_dispatch + 1100
    frame #7: 0x0000d706 coder_crash`rb_scope__run_test__(self=0x077a12c0) + 934 at app_delegate.rb:22
    frame #8: 0x0013ef3d coder_crash`dispatch_rimp_caller(objc_object* (*)(objc_object*, objc_selector*, ...), unsigned long, objc_selector, int, unsigned long const*) + 46445
    frame #9: 0x0012593a coder_crash`rb_vm_dispatch + 6474
    frame #10: 0x00004f6c coder_crash`vm_dispatch + 1100
    frame #11: 0x0000cbf7 coder_crash`rb_scope__application:didFinishLaunchingWithOptions:__(self=0x077a12c0, application=0x078f35e0, launchOptions=0x00000004) + 119 at app_delegate.rb:3
    frame #12: 0x0000cc6f coder_crash`__unnamed_20 + 95
    frame #13: 0x0055f157 UIKit`-[UIApplication _handleDelegateCallbacksWithOptions:isSuspended:restoreState:] + 266
    frame #14: 0x0055f747 UIKit`-[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1248
    frame #15: 0x0056094b UIKit`-[UIApplication _runWithURL:payload:launchOrientation:statusBarStyle:statusBarHidden:] + 805
    frame #16: 0x00571cb5 UIKit`-[UIApplication handleEvent:withNewEvent:] + 1022
    frame #17: 0x00572beb UIKit`-[UIApplication sendEvent:] + 85
    frame #18: 0x00564698 UIKit`_UIApplicationHandleEvent + 9874
    frame #19: 0x03130df9 GraphicsServices`_PurpleEventCallback + 339
    frame #20: 0x03130ad0 GraphicsServices`PurpleEventCallback + 46
    frame #21: 0x0180ebf5 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 53
    frame #22: 0x0180e962 CoreFoundation`__CFRunLoopDoSource1 + 146
    frame #23: 0x0183fbb6 CoreFoundation`__CFRunLoopRun + 2118
    frame #24: 0x0183ef44 CoreFoundation`CFRunLoopRunSpecific + 276
    frame #25: 0x0183ee1b CoreFoundation`CFRunLoopRunInMode + 123
    frame #26: 0x0056017a UIKit`-[UIApplication _run] + 774
    frame #27: 0x00561ffc UIKit`UIApplicationMain + 1211
    frame #28: 0x000039bc coder_crash`main(argc=1, argv=0xbffff018) + 156 at main.mm:15
(lldb) c
Process 2194 resuming
Process 2194 stopped
* thread #6: tid = 0xfcb013, 0x0020509b libobjc.A.dylib`objc_msgSend + 15, queue = 'coding_test_archive', stop reason = EXC_BAD_ACCESS (code=1, address=0x50000008)
    frame #0: 0x0020509b libobjc.A.dylib`objc_msgSend + 15
libobjc.A.dylib`objc_msgSend + 15:
-> 0x20509b:  movl   0x8(%edx), %edi
   0x20509e:  pushl  %esi
   0x20509f:  movl   (%edi), %esi
   0x2050a1:  movl   %ecx, %edx
(lldb) bt
* thread #6: tid = 0xfcb013, 0x0020509b libobjc.A.dylib`objc_msgSend + 15, queue = 'coding_test_archive', stop reason = EXC_BAD_ACCESS (code=1, address=0x50000008)
  * frame #0: 0x0020509b libobjc.A.dylib`objc_msgSend + 15
    frame #1: 0x0107446b Foundation`+[NSKeyedUnarchiver unarchiveObjectWithFile:] + 280
    frame #2: 0x0000324e coder_crash`__17-[BCArchive get:]_block_invoke(.block_descriptor=<unavailable>) + 190 at archive.m:23
    frame #3: 0x0264a53f libdispatch.dylib`_dispatch_call_block_and_release + 15
    frame #4: 0x0265c014 libdispatch.dylib`_dispatch_client_callout + 14
    frame #5: 0x0264c418 libdispatch.dylib`_dispatch_queue_drain + 239
    frame #6: 0x0264c2a6 libdispatch.dylib`_dispatch_queue_invoke + 59
    frame #7: 0x0264d280 libdispatch.dylib`_dispatch_root_queue_drain + 231
    frame #8: 0x0264d450 libdispatch.dylib`_dispatch_worker_thread2 + 39
    frame #9: 0x02b5bdab libsystem_pthread.dylib`_pthread_wqthread + 336
```
