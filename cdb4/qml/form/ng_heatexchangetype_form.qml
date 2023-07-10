<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="convectivefraction" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="convectivefraction_uom" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="latentfraction" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="latentfraction_uom" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="radiantfraction" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="radiantfraction_uom" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="totalvalue" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="totalvalue_uom" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="0"/>
    <alias field="convectivefraction" name="Convective Fraction" index="1"/>
    <alias field="convectivefraction_uom" name="Convective Fraction UoM" index="2"/>
    <alias field="latentfraction" name="Latent Fraction" index="3"/>
    <alias field="latentfraction_uom" name="Latent Fraction UoM" index="4"/>
    <alias field="radiantfraction" name="Radiant Fraction" index="5"/>
    <alias field="radiantfraction_uom" name="Radiant Fraction UoM" index="6"/>
    <alias field="totalvalue" name="Total Value" index="7"/>
    <alias field="totalvalue_uom" name="Total Value UoM" index="8"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="id" constraints="3" exp_strength="0" unique_strength="1"/>
    <constraint notnull_strength="0" field="convectivefraction" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="convectivefraction_uom" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="latentfraction" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="latentfraction_uom" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="radiantfraction" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="radiantfraction_uom" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="totalvalue" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="totalvalue_uom" constraints="4" exp_strength="1" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="convectivefraction" desc="Both values must either be NULL or NOT NULL" exp="(&quot;convectivefraction&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;convectivefraction_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;convectivefraction&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;convectivefraction_uom&quot; IS NULL)"/>
    <constraint field="convectivefraction_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;convectivefraction&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;convectivefraction_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;convectivefraction&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;convectivefraction_uom&quot; IS NULL)"/>
    <constraint field="latentfraction" desc="Both values must either be NULL or NOT NULL" exp="(&quot;latentfraction&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;latentfraction_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;latentfraction&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;latentfraction_uom&quot; IS NULL)"/>
    <constraint field="latentfraction_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;latentfraction&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;latentfraction_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;latentfraction&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;latentfraction_uom&quot; IS NULL)"/>
    <constraint field="radiantfraction" desc="Both values must either be NULL or NOT NULL" exp="(&quot;radiantfraction&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;radiantfraction_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;radiantfraction&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;radiantfraction_uom&quot; IS NULL)"/>
    <constraint field="radiantfraction_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;radiantfraction&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;radiantfraction_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;radiantfraction&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;radiantfraction_uom&quot; IS NULL)"/>
    <constraint field="totalvalue" desc="Both values must either be NULL or NOT NULL" exp="(&quot;totalvalue&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;totalvalue_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;totalvalue&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;totalvalue_uom&quot; IS NULL)"/>
    <constraint field="totalvalue_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;totalvalue&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;totalvalue_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;totalvalue&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;totalvalue_uom&quot; IS NULL)"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorField name="id" showLabel="1" index="0"/>
    <attributeEditorField name="convectivefraction" showLabel="1" index="1"/>
    <attributeEditorField name="convectivefraction_uom" showLabel="1" index="2"/>
    <attributeEditorField name="latentfraction" showLabel="1" index="3"/>
    <attributeEditorField name="latentfraction_uom" showLabel="1" index="4"/>
    <attributeEditorField name="radiantfraction" showLabel="1" index="5"/>
    <attributeEditorField name="radiantfraction_uom" showLabel="1" index="6"/>
    <attributeEditorField name="totalvalue" showLabel="1" index="7"/>
    <attributeEditorField name="totalvalue_uom" showLabel="1" index="8"/>
  </attributeEditorForm>
  <editable>
    <field name="id" editable="0"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
