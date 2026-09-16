```text

- Our plan is minimal right now. Once we reach the exception vectors, my design is that we build a software exception context frame as ofcourse that is what 
will be used to deal with current exception and also establish any change we might need in order to address this exception, and that same software context
will also display the desired return state we want at the time of ERET.

This exception context frame will be built in software, and the split between assembly and C is that:
- Assembly owns the architectural mechanical entry and exit, and creating the stack frame for our exception context
- C works as the dispatcher, where it handles the policy, handling and resolution of the exception.

Now, yes the issue of a shared struct comes here, because our assembly will construct a frame of the exception context and that frame will be passed 
to the C via normal calling convention, so for that there is need of a shared contract between both codes in a sense that assembly will create the frame
in accordance with the compiler generated offsets of each members of that struct, that is achieved using tools/generate-axiom-exception-ctx-offsets program
and the generated header will be saved in include/generated/axiom-exception-ctx-offset.h header file

```
