<?php

declare(strict_types=1);

namespace App\Http\Requests;

abstract class RequestBase
{
    abstract public function authorize(): bool;
    abstract public function rules(): array;
}
