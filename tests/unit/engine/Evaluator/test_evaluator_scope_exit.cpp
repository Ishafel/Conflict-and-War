#include <catch2/catch_test_macros.hpp>
#include <Evaluator/express.hpp>

namespace
{
class ScopeDiagnostics : public GameStateInfoFunctions
{
    GameStateInfoFunctions* _previous = GameState::DefaultInfoFunctions();

  public:
    ScopeDiagnostics() { GameState::SetDefaultInfoFunctions(this); }
    ~ScopeDiagnostics() override { GameState::SetDefaultInfoFunctions(_previous); }
    const char* GetErrorString(EvalError error) const override
    {
        return error == EvalDivZero ? "division by zero" : "script error";
    }
};

void RequireEqual(GameValuePar actual, GameValuePar expected)
{
    REQUIRE(actual.GetType() == expected.GetType());
    if (actual.GetType() == GameArray)
    {
        const GameArrayType& a = actual;
        const GameArrayType& b = expected;
        REQUIRE(a.Size() == b.Size());
        for (int i = 0; i < a.Size(); ++i)
            RequireEqual(a[i], b[i]);
    }
    else
        REQUIRE(actual.IsEqualTo(expected));
}

void RequireResult(GameState& state, const char* script, const char* expected)
{
    INFO(script);
    const GameValue result = state.EvaluateMultiple(script);
    REQUIRE(state.GetLastError() == EvalOK);
    const GameValue reference = state.EvaluateMultiple(expected);
    REQUIRE(state.GetLastError() == EvalOK);
    RequireEqual(result, reference);
}
} // namespace

TEST_CASE("Evaluator scope exit - calls return values and resume caller", "[evaluator][scope-exit]")
{
    GameState state;
    state.Init();
    SECTION("unary call assignment")
    {
        RequireResult(state, "v=0;x=call {if(true) exitWith {7};v=9;0};[x,v,11]", "[7,0,11]");
    }
    SECTION("binary call arguments")
    {
        RequireResult(state, "v=0;x=5 call {if(true) exitWith {_this+2};v=9;0};[x,v,11]", "[7,0,11]");
    }
    SECTION("nested calls and argument restoration")
    {
        RequireResult(state,
                      "x=5 call {private [\"_r\"];_r=2 call {if(true) exitWith {_this+1};0};"
                      "if(true) exitWith {[_r,_this]};0};[x,11]",
                      "[[3,5],11]");
    }
    SECTION("false condition")
    {
        RequireResult(state, "x=call {if(false) exitWith {7};9};[x,11]", "[9,11]");
    }
    SECTION("string and array values")
    {
        RequireResult(state,
                      "[call {if(true) exitWith {\"ready\"};0},"
                      "call {if(true) exitWith {[1,2]};0}]",
                      "[\"ready\",[1,2]]");
    }
    SECTION("nothing exit")
    {
        RequireResult(state, "v=0;call {if(true) exitWith {};v=100};v=v+1;v", "1");
    }
}

TEST_CASE("Evaluator scope exit - loop boundaries", "[evaluator][scope-exit]")
{
    GameState state;
    state.Init();
    SECTION("for direct exit")
    {
        RequireResult(state, "v=0;x=for \"_i\" from 1 to 3 do {v=v+1;if(true) exitWith {7};v=100};[v,x,11]",
                      "[1,7,11]");
    }
    SECTION("while direct exit")
    {
        RequireResult(state, "v=0;x=while {v<3} do {v=v+1;if(true) exitWith {7};v=100};[v,x,11]", "[1,7,11]");
    }
    SECTION("forEach direct exit")
    {
        RequireResult(state, "v=0;{v=v+1;if(true) exitWith {7};v=100} forEach [1,2,3];[v,11]", "[1,11]");
    }
    SECTION("helper does not break caller loop")
    {
        RequireResult(state, "v=0;for \"_i\" from 1 to 3 do {x=call {if(true) exitWith {7};0};v=v+x};v", "21");
    }
    SECTION("then exit does not break caller loop")
    {
        RequireResult(state, "v=0;for \"_i\" from 1 to 3 do {if(true) then {if(true) exitWith {7};v=100};v=v+1};v",
                      "3");
    }
    SECTION("else value")
    {
        RequireResult(state, "x=if(false) then {0} else {if(true) exitWith {9};0};[x,11]", "[9,11]");
    }
    SECTION("nested loops retain separate results")
    {
        RequireResult(state,
                      "v=0;x=for \"_i\" from 1 to 3 do {y=for \"_j\" from 1 to 3 do {"
                      "if(true) exitWith {4}};v=v+y;if(_i==2) exitWith {8}};[v,x]",
                      "[8,8]");
    }
}

TEST_CASE("Evaluator scope exit - genuine child errors survive", "[evaluator][scope-exit]")
{
    ScopeDiagnostics diagnostics;
    GameState state;
    state.Init();
    const char* script = nullptr;
    SECTION("call")
    {
        script = "marker=0;x=call {1/0};marker=1";
    }
    SECTION("binary call")
    {
        script = "marker=0;x=5 call {1/0};marker=1";
    }
    SECTION("exit body")
    {
        script = "marker=0;call {if(true) exitWith {1/0}};marker=1";
    }
    SECTION("then")
    {
        script = "marker=0;if(true) then {1/0};marker=1";
    }
    SECTION("for")
    {
        script = "marker=0;for \"_i\" from 1 to 3 do {1/0};marker=1";
    }
    SECTION("while condition")
    {
        script = "marker=0;while {1/0} do {marker=2};marker=1";
    }
    SECTION("while body")
    {
        script = "marker=0;while {true} do {1/0};marker=1";
    }
    SECTION("forEach")
    {
        script = "marker=0;{1/0} forEach [1,2];marker=1";
    }
    state.EvaluateMultiple(script);
    REQUIRE(state.GetLastError() == EvalDivZero);
    REQUIRE(state.GetLastErrorText() == RString("division by zero"));
    REQUIRE(state.GetLastErrorPos() > 0);
    REQUIRE(float(state.VarGet("marker")) == 0.0f);
}

TEST_CASE("Evaluator scope exit - top level and independent states", "[evaluator][scope-exit]")
{
    GameState first, second;
    first.Init();
    second.Init();
    const auto result = first.EvaluateMultiple("if(true) exitWith {[7,8]};0");
    REQUIRE(first.GetLastError() == EvalBreak);
    REQUIRE(result.GetType() == GameArray);
    const GameArrayType& values = result;
    REQUIRE(values.Size() == 2);
    REQUIRE(float(values[0]) == 7.0f);
    const auto assigned = first.EvaluateMultiple("marker=0;x=if(true) exitWith {9};marker=1");
    REQUIRE(first.GetLastError() == EvalBreak);
    REQUIRE(assigned.GetType() == GameScalar);
    REQUIRE(float(assigned) == 9.0f);
    REQUIRE(float(first.VarGet("marker")) == 0.0f);
    RequireResult(second, "x=call {if(true) exitWith {3};0};[x,11]", "[3,11]");
    RequireResult(first, "x=call {if(false) exitWith {99};4};[x,11]", "[4,11]");
}
