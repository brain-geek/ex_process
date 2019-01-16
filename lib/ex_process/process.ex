defmodule ExProcess.Process do
  @moduledoc """
  Struct to store process.
  """
  @enforce_keys [:id]
  defstruct name: "",
            # Barebones of the process, see examples here:
            # https://www.lucidchart.com/pages/bpmn-activity-types
            activities: [],

            # See http://blog.goodelearning.com/subject-areas/bpmn/bpmn-2-0-terms-explained-process-flows/
            # for flow types, there are quite a lot.
            flows: [],

            # See https://www.lucidchart.com/pages/bpmn-event-types for examples
            # Basically, there are three kinds of events:
            # - Start event: is active when process starts;
            #   While "proper" business process requires start event to be present,
            #   we don't verify it for more flexibility
            # - Intermediate events: messages received/sent as a part of process
            # - End events: generally end the process
            events: [],
            id: nil

  defmodule Task do
    @moduledoc """
    Struct to store process part: separate task.
    """

    @enforce_keys [:id]
    defstruct name: "", id: nil
  end

  defmodule MessageThrowEvent do
    @moduledoc """
    Struct to store process part: message throw event.

    They are mostly triggered from outside the process.
    """

    @enforce_keys [:id]
    defstruct name: "", id: nil
  end

  defmodule MessageCatchEvent do
    @moduledoc """
    Struct to store process part: message catch event.

    They are mostly triggered from outside the process.
    """

    @enforce_keys [:id]
    defstruct name: "", id: nil
  end

  defmodule StartEvent do
    @moduledoc """
    Struct to store process part: start event.

    When starting, all start events will start by being active
    """

    @enforce_keys [:id]
    defstruct name: "", id: nil
  end

  defmodule EndEvent do
    @moduledoc """
    Struct to store process part: end event.
    """

    @enforce_keys [:id]
    defstruct name: "", id: nil
  end

  defmodule ExclusiveGateway do
    @moduledoc """
    Struct to store process part: exclusive gateway.
    """

    @enforce_keys [:id]
    defstruct name: "", id: nil
  end

  defmodule Flow do
    @moduledoc """
    Struct to store process part: flow without condition.

    Flow is a link between two states.
    """

    @enforce_keys [:id, :from, :to]
    defstruct name: "", id: nil, from: [], to: []
  end

  defmodule ConditionalFlow do
    @moduledoc """
    Struct to store process part: flow with condition.

    Flow is a link between two states.

    Note: we don't use condition field separately from name at the moment
    due to BPMN visual editor used at the moment can't edit it.

    TODO: separate name and condition at the time of parsing.
    """

    @enforce_keys [:id, :from, :to, :condition]
    defstruct name: "", id: nil, from: [], to: [], condition: nil
  end
end
