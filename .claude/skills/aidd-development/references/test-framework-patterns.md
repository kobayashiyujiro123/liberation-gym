# Test Framework Patterns Reference

各言語・フレームワークにおけるテストパターンのリファレンス。
test-implementerとfeature-implementerが参照する。

---

## JavaScript / TypeScript

### Vitest

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // or 'jsdom' for browser
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
});
```

```typescript
// example.test.ts
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// Basic test
describe('Calculator', () => {
  it('adds two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });
});

// Mock
vi.mock('./database', () => ({
  query: vi.fn().mockResolvedValue([{ id: 1 }]),
}));

// Spy
const spy = vi.spyOn(object, 'method');

// Timer mock
vi.useFakeTimers();
vi.advanceTimersByTime(1000);

// Snapshot
expect(component).toMatchSnapshot();
```

**ファイル配置**:
- `src/__tests__/` or `tests/`
- `*.test.ts` / `*.spec.ts`
- 実行: `npx vitest run`
- カバレッジ: `npx vitest run --coverage`

### Jest

```typescript
// jest.config.ts
export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  collectCoverage: true,
};
```

```typescript
// example.test.ts
describe('Calculator', () => {
  it('adds two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });
});

// Mock
jest.mock('./database');
const mockQuery = jest.fn().mockResolvedValue([{ id: 1 }]);

// Timer
jest.useFakeTimers();
jest.advanceTimersByTime(1000);
```

**ファイル配置**:
- `__tests__/` or `*.test.ts`
- 実行: `npx jest`
- カバレッジ: `npx jest --coverage`

### Testing Library (React)

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
  it('submits the form with valid credentials', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockSubmit} />);

    await user.type(screen.getByLabelText('Email'), 'test@example.com');
    await user.type(screen.getByLabelText('Password'), 'password123');
    await user.click(screen.getByRole('button', { name: 'Login' }));

    expect(mockSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });
});
```

---

## Python

### pytest

```python
# conftest.py
import pytest

@pytest.fixture
def sample_user():
    return User(name="Alice", age=30)

@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()
```

```python
# test_calculator.py
import pytest
from calculator import add, divide

class TestAdd:
    def test_adds_two_positive_numbers(self):
        assert add(1, 2) == 3

    def test_adds_negative_numbers(self):
        assert add(-1, -2) == -3

    @pytest.mark.parametrize("a, b, expected", [
        (0, 0, 0),
        (1, -1, 0),
        (100, 200, 300),
    ])
    def test_adds_various_numbers(self, a, b, expected):
        assert add(a, b) == expected

class TestDivide:
    def test_raises_on_zero_division(self):
        with pytest.raises(ZeroDivisionError):
            divide(1, 0)
```

```python
# Mock
from unittest.mock import Mock, patch, MagicMock

@patch('module.external_api')
def test_with_mock(mock_api):
    mock_api.return_value = {"status": "ok"}
    result = process_data()
    assert result == expected
    mock_api.assert_called_once()
```

**ファイル配置**:
- `tests/` directory
- `test_*.py` / `*_test.py`
- 実行: `pytest`
- カバレッジ: `pytest --cov=src --cov-report=term-missing`

---

## Go

### Standard Testing

```go
// calculator_test.go
package calculator

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestAdd(t *testing.T) {
    t.Run("adds two positive numbers", func(t *testing.T) {
        result := Add(1, 2)
        assert.Equal(t, 3, result)
    })

    t.Run("adds negative numbers", func(t *testing.T) {
        result := Add(-1, -2)
        assert.Equal(t, -3, result)
    })
}

// Table-driven tests
func TestDivide(t *testing.T) {
    tests := []struct {
        name     string
        a, b     float64
        expected float64
        wantErr  bool
    }{
        {"positive division", 10, 2, 5, false},
        {"division by zero", 1, 0, 0, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := Divide(tt.a, tt.b)
            if tt.wantErr {
                require.Error(t, err)
                return
            }
            require.NoError(t, err)
            assert.Equal(t, tt.expected, result)
        })
    }
}
```

```go
// Mock with interface
type MockDB struct {
    mock.Mock
}

func (m *MockDB) GetUser(id int) (*User, error) {
    args := m.Called(id)
    return args.Get(0).(*User), args.Error(1)
}
```

**ファイル配置**:
- 同一パッケージ内に `*_test.go`
- 実行: `go test ./...`
- カバレッジ: `go test -coverprofile=coverage.out ./...`

---

## Ruby

### RSpec

```ruby
# spec/calculator_spec.rb
RSpec.describe Calculator do
  describe '#add' do
    it 'adds two positive numbers' do
      calculator = Calculator.new
      expect(calculator.add(1, 2)).to eq(3)
    end

    context 'with negative numbers' do
      it 'returns the correct sum' do
        expect(Calculator.new.add(-1, -2)).to eq(-3)
      end
    end
  end

  describe '#divide' do
    it 'raises an error when dividing by zero' do
      expect { Calculator.new.divide(1, 0) }.to raise_error(ZeroDivisionError)
    end
  end
end
```

```ruby
# Mock/Stub
allow(api_client).to receive(:fetch).and_return({ status: 'ok' })
expect(api_client).to have_received(:fetch).once
```

**ファイル配置**:
- `spec/` directory
- `*_spec.rb`
- 実行: `bundle exec rspec`
- カバレッジ: SimpleCov gem

---

## Java

### JUnit 5

```java
// CalculatorTest.java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    private Calculator calculator;

    @BeforeEach
    void setUp() {
        calculator = new Calculator();
    }

    @Test
    @DisplayName("adds two positive numbers")
    void addsTwoPositiveNumbers() {
        assertEquals(3, calculator.add(1, 2));
    }

    @ParameterizedTest
    @CsvSource({"0,0,0", "1,-1,0", "100,200,300"})
    void addsVariousNumbers(int a, int b, int expected) {
        assertEquals(expected, calculator.add(a, b));
    }

    @Test
    void throwsOnDivisionByZero() {
        assertThrows(ArithmeticException.class,
            () -> calculator.divide(1, 0));
    }
}
```

**ファイル配置**:
- `src/test/java/` (Maven/Gradle standard)
- `*Test.java`
- 実行: `mvn test` / `gradle test`

---

## Common Assertion Patterns

| パターン | JavaScript (Vitest/Jest) | Python (pytest) | Go (testify) |
|---|---|---|---|
| 等値 | `expect(a).toBe(b)` | `assert a == b` | `assert.Equal(t, b, a)` |
| 深い等値 | `expect(a).toEqual(b)` | `assert a == b` | `assert.Equal(t, b, a)` |
| 真偽 | `expect(a).toBeTruthy()` | `assert a` | `assert.True(t, a)` |
| null | `expect(a).toBeNull()` | `assert a is None` | `assert.Nil(t, a)` |
| 例外 | `expect(() => f()).toThrow()` | `pytest.raises(E)` | `assert.Panics(t, f)` |
| 含む | `expect(a).toContain(b)` | `assert b in a` | `assert.Contains(t, a, b)` |
| 近似 | `expect(a).toBeCloseTo(b)` | `assert a == pytest.approx(b)` | `assert.InDelta(t, b, a, d)` |
