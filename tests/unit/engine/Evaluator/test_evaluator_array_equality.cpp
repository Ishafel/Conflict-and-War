#include <catch2/catch_test_macros.hpp>
#include <Evaluator/express.hpp>

#include <cmath>
#include <initializer_list>
#include <limits>

namespace
{
GameValue Array(std::initializer_list<GameValue> values)
{
    GameArrayType array;
    for (const GameValue& value : values)
        array.Add(value);
    return GameValue(array);
}
} // namespace

// 005 FR-001/002: compare values, including independent and shared nested arrays.
TEST_CASE("Array value equality - structural contents", "[evaluator][array-equality]")
{
    const GameValue empty = Array({});
    CHECK(empty.IsEqualTo(Array({})));
    const GameValue mixed = Array({1.0f, true, "Alpha", Array({})});
    const GameValue independent = Array({1.0f, true, "Alpha", Array({})});
    CHECK(mixed.GetData() != independent.GetData());
    CHECK(mixed.IsEqualTo(independent));
    CHECK(independent.IsEqualTo(mixed));
    CHECK(mixed.IsEqualTo(mixed));

    const GameValue child = Array({2.0f, false});
    const GameValue shared = Array({child, child, empty});
    const GameValue nested = Array({Array({2.0f, false}), Array({2.0f, false}), Array({})});
    CHECK(shared.IsEqualTo(nested));
    CHECK(nested.IsEqualTo(shared));

    CHECK_FALSE(empty.IsEqualTo(Array({1.0f})));
    CHECK_FALSE(Array({1.0f, 2.0f}).IsEqualTo(Array({2.0f, 1.0f})));
    CHECK_FALSE(Array({1.0f, 2.0f}).IsEqualTo(Array({1.0f, 3.0f})));
    CHECK_FALSE(Array({Array({1.0f})}).IsEqualTo(Array({Array({2.0f})})));
    CHECK_FALSE(Array({Array({})}).IsEqualTo(empty));
}

TEST_CASE("Array value equality - leaf semantics remain unchanged", "[evaluator][array-equality]")
{
    CHECK(Array({false, 0.0f, "Alpha"}).IsEqualTo(Array({false, 0.0f, "Alpha"})));
    CHECK_FALSE(Array({true}).IsEqualTo(Array({1.0f})));
    CHECK_FALSE(Array({"Alpha"}).IsEqualTo(Array({"alpha"})));
    CHECK_FALSE(Array({1.0f}).IsEqualTo(Array({std::nextafter(1.0f, 2.0f)})));
    CHECK_FALSE(Array({}).IsEqualTo(GameValue(0.0f)));

    const GameValue nothing = Array({GameValue()});
    const GameValue nil = Array({GameValue(new GameDataNil(GameScalar))});
    const GameValue nan = Array({std::numeric_limits<float>::quiet_NaN()});
    CHECK_FALSE(nothing.IsEqualTo(nothing));
    CHECK_FALSE(nil.IsEqualTo(nil));
    CHECK_FALSE(nan.IsEqualTo(nan));
    CHECK_FALSE(Array({nothing}).IsEqualTo(Array({nothing})));
}

TEST_CASE("Array value equality - no mutation or stale result", "[evaluator][array-equality]")
{
    GameValue child = Array({1.0f});
    GameValue left = Array({child, child});
    const GameValue right = Array({Array({1.0f}), Array({1.0f})});
    CHECK(left.IsEqualTo(right));
    const GameArrayType& leftValues = left;
    const GameArrayType& rightValues = right;
    REQUIRE(leftValues.Size() == 2);
    REQUIRE(rightValues.Size() == 2);
    CHECK(leftValues[0].GetData() == child.GetData());
    CHECK(leftValues[1].GetData() == child.GetData());
    CHECK(leftValues[0].GetData() != rightValues[0].GetData());
    GameArrayType& childValues = child;
    childValues[0] = 2.0f;
    CHECK_FALSE(left.IsEqualTo(right));
    const GameArrayType& rightChild = rightValues[0];
    CHECK(static_cast<float>(rightChild[0]) == 1.0f);
    childValues[0] = 1.0f;
    CHECK(left.IsEqualTo(right));
}

TEST_CASE("Array value equality - membership and find", "[evaluator][array-equality]")
{
    GameState state;
    state.Init();
    for (const char* script : {"[1,2] in [[1,2],[3]]", "[] in [[],[1]]", "[1,[2,true]] in [[1,[2,true]]]"})
    {
        INFO(script);
        const GameValue result = state.EvaluateMultiple(script);
        REQUIRE(state.GetLastError() == EvalOK);
        REQUIRE(result.GetType() == GameBool);
        CHECK(static_cast<bool>(result));
    }
    const GameValue found = state.EvaluateMultiple("[[3],[1,2],[1,2]] find [1,2]");
    REQUIRE(state.GetLastError() == EvalOK);
    REQUIRE(found.GetType() == GameScalar);
    CHECK(static_cast<float>(found) == 1.0f);
    const GameValue missing = state.EvaluateMultiple("[[1,2]] find [2,1]");
    REQUIRE(state.GetLastError() == EvalOK);
    CHECK(static_cast<float>(missing) == -1.0f);
}

TEST_CASE("Array value equality - subtraction preserves unmatched order", "[evaluator][array-equality]")
{
    GameState state;
    state.Init();
    const GameValue result = state.EvaluateMultiple("[[1,2],[3],[1,2],[],[4]] - [[1,2],[]]");
    REQUIRE(state.GetLastError() == EvalOK);
    REQUIRE(result.GetType() == GameArray);
    const GameArrayType& values = result;
    REQUIRE(values.Size() == 2);
    for (int i = 0; i < values.Size(); ++i)
    {
        REQUIRE(values[i].GetType() == GameArray);
        const GameArrayType& child = values[i];
        REQUIRE(child.Size() == 1);
        CHECK(static_cast<float>(child[0]) == float(i + 3));
    }
}

TEST_CASE("Array value equality - cyclic assignment remains rejected", "[evaluator][array-equality]")
{
    GameState state;
    state.Init();
    SECTION("direct cycle")
    {
        state.EvaluateMultiple("a=[];a set [0,a]");
        CHECK(state.GetLastError() == EvalDim);
    }
    SECTION("indirect cycle")
    {
        state.EvaluateMultiple("a=[];b=[a];a set [0,b]");
        CHECK(state.GetLastError() == EvalDim);
    }
}
